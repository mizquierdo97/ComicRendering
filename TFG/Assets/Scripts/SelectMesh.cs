using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SelectMesh : MonoBehaviour {

    Dropdown dropdown;
    GameObject actualGO = null;
    public GameObject cube = null;
    public GameObject prop1 = null;
    public GameObject prop2 = null;
    public GameObject prop3 = null;
    public GameObject prop4 = null;
    public GameObject build = null;
    public CameraRenderScript renderScript;
    public MSCameraController camController;
    public GameObject bottomPlane = null;
    // Use this for initialization
    void Start () {
        dropdown = GetComponent<Dropdown>();
        prop3.SetActive(true);
        actualGO = prop3;

    }
	
	// Update is called once per frame
	void Update () {
       
	}


    public void ChangeMesh()
    {
        int value = dropdown.value;
        string name = dropdown.options[value].text;
        actualGO.SetActive(false);
        switch (value)
        {
            case 0:
                {
                    cube.SetActive(true);
                    actualGO = cube;
                    renderScript.DepthWidth = 4.0f;
                    renderScript.DepthThreshold = 0.001f;
                    camController.CameraSettings.orbital.minDistance = 5.0f;
                    camController.CameraSettings.orbital.maxDistance = 25.0f;
                    bottomPlane.transform.localScale = new Vector3(3.0f, 3.0f, 3.0f);
                }
                break;
            case 1:
                {
                    prop1.SetActive(true);
                    actualGO = prop1;
                    renderScript.DepthWidth = 1.0f;
                    renderScript.DepthThreshold = 0.002f;
                    camController.CameraSettings.orbital.minDistance = 5.0f;
                    camController.CameraSettings.orbital.maxDistance = 25.0f;
                    bottomPlane.transform.localScale = new Vector3(3.0f, 3.0f, 3.0f);
                }
                break;
            case 2:
                {
                    prop2.SetActive(true);
                    actualGO = prop2;
                    renderScript.DepthWidth = 4.0f;
                    renderScript.DepthThreshold = 0.001f;
                    camController.CameraSettings.orbital.minDistance = 5.0f;
                    camController.CameraSettings.orbital.maxDistance = 25.0f;
                    bottomPlane.transform.localScale = new Vector3(3.0f, 3.0f, 3.0f);
                }
                break;
            case 3:
                {
                    prop3.SetActive(true);
                    actualGO = prop3;
                    renderScript.DepthWidth = 4.0f;
                    renderScript.DepthThreshold = 0.001f;
                    camController.CameraSettings.orbital.minDistance = 5.0f;
                    camController.CameraSettings.orbital.maxDistance = 25.0f;
                    bottomPlane.transform.localScale = new Vector3(3.0f, 3.0f, 3.0f);
                }
                break;
            case 4:
                {
                    prop4.SetActive(true);
                    actualGO = prop4;
                    renderScript.DepthWidth = 4.0f;
                    renderScript.DepthThreshold = 0.001f;
                    camController.CameraSettings.orbital.minDistance = 5.0f;
                    camController.CameraSettings.orbital.maxDistance = 25.0f;
                    bottomPlane.transform.localScale = new Vector3(3.0f, 3.0f, 3.0f);
                }
                break;
            case 5:
                {
                    build.SetActive(true);
                    actualGO = build;
                    renderScript.DepthWidth = 1.0f;
                    renderScript.DepthThreshold = 0.01f;
                    camController.CameraSettings.orbital.minDistance = 25.0f;
                    camController.CameraSettings.orbital.maxDistance = 50.0f;
                    bottomPlane.transform.localScale = new Vector3(8.0f, 8.0f, 8.0f);
                }
                break;
        }
    }
}
