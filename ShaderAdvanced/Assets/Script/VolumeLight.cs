using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VolumeLight : MonoBehaviour
{
    public Transform lightTransform;
    private Material godRayVolumeMateril;


    void Awake()
    {
        var renderer = GetComponentInChildren<Renderer>();
        foreach (var mat in renderer.sharedMaterials)
        {
            if (mat.shader.name.Contains("体积光"))
                godRayVolumeMateril = mat;
        }
    }


    // Update is called once per frame  
    void Update()
    {
        if (lightTransform ==null  || godRayVolumeMateril == null)
            return;
        float distance = Vector3.Distance(lightTransform.position, transform.position);//做衰减用的控制量
        godRayVolumeMateril.SetVector("_WorldLightPos", new Vector4(lightTransform.position.x, lightTransform.position.y, lightTransform.position.z, distance));
    }
}
