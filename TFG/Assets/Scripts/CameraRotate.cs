using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRotate : MonoBehaviour
{
    public Transform cameraOrbit;
    public Transform target;

    float a = 0.0f;
void Start()
    {
        //cameraOrbit.position = target.position;
    }

    void Update()
    {
        a += Time.deltaTime * 4;
        transform.rotation = Quaternion.Euler(12, transform.rotation.y + a, transform.rotation.z);

        //transform.LookAt(cameraOrbit.position);
    }
}