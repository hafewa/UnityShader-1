using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetTextureUVNumbers : MonoBehaviour {


	public int width = 3;

	public int hight = 3;

	public float fps = 10.0f;

	private int index;

	private float frame;

	private Material mat;

	private float Scale_x;

	private float Scale_y;

	private float Offset_x;

	private float Offset_y;

	private int NumCount;

	void Start () 
	{
        frame = (float)1.0 / fps;

		mat = GetComponent<Renderer> ().material;

		Scale_x = (float)1.0 / width;

		Scale_y = (float)1.0 / hight;

		NumCount = width * hight;
	}
	

	void Update () 
	{
        frame -= Time.deltaTime;

		if (frame <= 0) 
		{
            frame = (float)1.0 / fps;

			Offset_x = (index % width) * Scale_x;

			Offset_y = ((NumCount - index-1) / hight) * Scale_y;

			mat.SetTextureScale ("_MainTex", new Vector2 (Scale_x, Scale_y));

			mat.SetTextureOffset ("_MainTex", new Vector2 (Offset_x, Offset_y));

			index++;

			index = index % NumCount;
		}
	}
}
