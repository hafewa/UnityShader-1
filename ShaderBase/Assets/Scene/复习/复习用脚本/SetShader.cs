using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetShader : MonoBehaviour
{
    //屏幕的最右边坐标也是流光的起点
    float dis = 1;
    float _R = 0.1f;

	void Update ()
    {
        dis -= Time.deltaTime * 0.7f;
        if (dis <= -1)
            dis = 1;//又会从最右边开始
        GetComponent<Renderer>().material.SetFloat("dis", dis);
        GetComponent<Renderer>().material.SetFloat("_R", _R);
    }
}
