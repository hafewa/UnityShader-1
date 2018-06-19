using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PassdataToShader : MonoBehaviour {

	//流光x轴上的起点
	private float dis = 1;

	//流光的x轴上的宽度
	private float rt = 0.1f;

	void Start () 
	{
		
	}
	
	// Update is called once per frame
	void Update () 
	{
		dis -= Time.deltaTime*0.7f;
		if (dis <= -1)
			dis = 1;

		GetComponent<Renderer> ().material.SetFloat ("dis", dis);
		GetComponent<Renderer> ().material.SetFloat ("rt", rt);
	}
}
