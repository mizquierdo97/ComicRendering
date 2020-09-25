using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class DiscreteRotation : MonoBehaviour 
{

	public Camera mainCam;
	Vector3 realRotation; Vector3 initialFwd;
	// Use this for initialization
	void Start () {
		realRotation = transform.forward;
		realRotation.y = 0.0f;
		initialFwd = mainCam.transform.forward;
		initialFwd.y = 0.0f;
	}
	
	// Update is called once per frame
	void Update () {
		Vector3 fwd = mainCam.transform.forward; //transform.position - mainCam.transform.position;
		fwd = (new Vector3(fwd.x, 0, fwd.z)).normalized;

        float offsetAngle = Vector3.SignedAngle(realRotation, initialFwd, Vector3.up);
        float angle =Vector3.SignedAngle(realRotation, fwd,Vector3.up);
        angle = (angle) % 22.5f;
		Debug.Log(angle);
		transform.forward = Quaternion.AngleAxis(angle, Vector3.up) * realRotation;
	}
}
