using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour {

    float a = 0.0f;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        a += Time.deltaTime * 60;
        transform.rotation = Quaternion.Euler(90, a, 0);
	}
}
