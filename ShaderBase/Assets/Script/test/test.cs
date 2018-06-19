using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class test : MonoBehaviour 
{
	private float dis = -1;

	private float r = 0.1f;
	void Start () 
	{
		
	}
	

	void Update () 
	{
		dis += Time.deltaTime;

		if (dis >= 1)
			dis = -1;

		this.GetComponent<Renderer> ().material.SetFloat ("dis", dis);
		this.GetComponent<Renderer> ().material.SetFloat ("r", r);
	}
}
