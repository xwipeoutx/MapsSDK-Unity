using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElevationScaleController : MonoBehaviour
{
    [SerializeField][Range(0, 4)] float elevationScale = 1;

    private int elevationScaleId;
    
    void Awake()
    {
        elevationScaleId = Shader.PropertyToID("_ElevationScale");
    }

    void Update()
    {
        Shader.SetGlobalFloat(elevationScaleId, elevationScale);
    }
}
