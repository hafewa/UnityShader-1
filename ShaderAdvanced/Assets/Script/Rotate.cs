using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour {

	public Transform center;
	
	// Update is called once per frame
	void Update () 
	{
		transform.RotateAround (center.position, Vector3.up, Time.deltaTime * 10);
	}
}
