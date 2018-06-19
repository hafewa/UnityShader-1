using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class test_Number : MonoBehaviour
{

    int width = 3;

    int hight = 3;

    int NumCount;

    Material mat;

    private float Scale_x;

    private float Scale_y;

    private float fram;

    public float fps = 10.0f;
    private float Offset_x;

    private float Offset_y;

    int index;

    void Start ()
    {
        NumCount = 3 * 3;
        mat = GetComponent<Renderer>().material;

        Scale_x = (float)1.0 / width;
        Scale_y = (float)1.0 / hight;

        fram = 1.0f/ fps;

        index = 0;
    }
	

	void Update ()
    {
        fram -= Time.deltaTime;

        if(fram <= 0)
        {
            fram = 1.0f / fps;

            Offset_x = (index % width) * Scale_x;

            Offset_y = ((NumCount - index - 1) / hight) * Scale_y;

            mat.SetTextureOffset("_MainTex", new Vector2(Offset_x, Offset_y));

            mat.SetTextureScale("_MainTex", new Vector2(Scale_x, Scale_y));

            index++;

            index = index % NumCount;
        }

    }
}
