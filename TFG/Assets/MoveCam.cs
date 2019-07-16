using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveCam : MonoBehaviour {

    public Camera cam;
    Transform trans;
	// Use this for initialization
	void Start () {
        trans = GetComponent<Transform>();
        trans.position = new Vector3(-3.0f, trans.position.y, trans.position.z);

    }
	
	// Update is called once per frame
	void Update () {
        trans.position = new Vector3(trans.position.x + Time.deltaTime, trans.position.y, trans.position.z);
        if(trans.position.x >= 3.0f)
            trans.position = new Vector3(-3.0f, trans.position.y, trans.position.z);
    }
}
