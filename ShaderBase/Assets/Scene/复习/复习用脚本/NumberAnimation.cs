using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NumberAnimation : MonoBehaviour
{
    float scale_x = 0;
    float scale_y = 0;
    float frame = 0;
    public int fps = 10;
    int maxCount = 0;
    int index = 0;
    int width = 3;
    int hight = 3;

    Material mat;

	// Use this for initialization
	void Start ()
    {
        frame = (float)1.0f / fps;
        scale_x = (float)1.0f / width;
        scale_y = (float)1.0f / hight;
        maxCount = width * hight;
        mat = GetComponent<Renderer>().material;
    }
	
	// Update is called once per frame
	void Update ()
    {
        frame -= Time.deltaTime;

        if (frame <= 0)
        {
            frame = 1.0f / fps;

            float offset_x = (index % width) * scale_x;
            float offset_y = ((maxCount - index - 1) / hight) * scale_y;
            mat.SetTextureScale("_MainTex", new Vector2(scale_x, scale_y));
            mat.SetTextureOffset("_MainTex", new Vector2(offset_x, offset_y));
            index++;

            //使得index不会超越maxCount
            index = index % maxCount;
        }
	}
}
