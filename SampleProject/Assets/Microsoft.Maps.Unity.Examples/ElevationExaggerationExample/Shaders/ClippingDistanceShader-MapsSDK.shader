// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

Shader "MapsSDK/ClippingDistanceShader"
{
    SubShader
    {
        Pass
        {
            Tags{ "RenderType" = "Opaque" }
            Cull front

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            // These are the maps specific keywords...
            #pragma multi_compile __ ENABLE_ELEVATION_TEXTURE
            #pragma multi_compile __ USE_R16_FOR_ELEVATION_TEXTURE

            #include "UnityCG.cginc"
            #include "ClippingVolume-MapsSDK.cginc"
            #include "ElevationOffset-MapsSDK.cginc"

            float3 _CameraPosition;
            float3 _CameraNormal;
            
            fixed _ElevationScale;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 cameraPosition : POSITION1;
            };

            v2f vert(appdata v)
            {
#if ENABLE_ELEVATION_TEXTURE
                float elevationOffset =
                    CalculateElevationOffset(
                        v.uv,
                        _ElevationTexScaleAndOffset.x,
                        _ElevationTexScaleAndOffset.yz,
                        _ElevationTexScaleAndOffset.w*_ElevationScale);
                v.vertex.y += elevationOffset;
#endif
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);

                float4x4 model = unity_ObjectToWorld;
                float4x4 view = UNITY_MATRIX_V;
                float4x4 projection = UNITY_MATRIX_P;
                
                // Hack - move the clipping plane to the appropriate spot to capture the full elevation
                view[2][3] = 0;
                
                float4x4 mvp = mul(mul(projection, view), model);
                o.pos = mul(mvp, v.vertex); 
                o.cameraPosition = UnityObjectToViewPos(v.vertex);

                return o;
            }

            float frag(v2f i) : SV_Target
            {
                // Calculate distance by using camera position/plane and the input worldSpacePosition.
                float distanceToCameraPlane = -i.cameraPosition.z;
                return distanceToCameraPlane;
            }
            ENDCG
        }
    }
}