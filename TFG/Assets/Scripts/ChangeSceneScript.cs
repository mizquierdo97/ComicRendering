using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ChangeSceneScript : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
    public void LoadDemoScene()
    {
        SceneManager.LoadScene("Chapter2", LoadSceneMode.Single);
    }
    public void LoadGeometryScene()
    {
        SceneManager.LoadScene("WebGLScene", LoadSceneMode.Single);
    }
    public void ReturnMainMenu()
    {
        SceneManager.LoadScene("Menu", LoadSceneMode.Single);
    }
    public void Exit()
    {
        Application.Quit();
    }
}
