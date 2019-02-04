using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectNormalsRender : MonoBehaviour {

    Camera cam;
    public RenderTexture objectNormals;
    public RenderTexture objectDepth;
    public Shader ObjectNormalsShader;
    public Shader ObjectDepthShader;
    // Use this for initialization
    void OnEnable()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.DepthNormals;
        cam.depthTextureMode |= DepthTextureMode.Depth;
        int width = Screen.width * 2;
        int height = Screen.height * 2;

        //objectNormals.width = width;
        //objectNormals.height = height;
        //objectNormals = new RenderTexture(width, height, 32, RenderTextureFormat.ARGBFloat);
        //objectNormals.Create();
        cam.targetTexture = objectNormals;
        cam.SetReplacementShader(ObjectNormalsShader, null);

        GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;

    }
    void Awake()
    {
       
    }
    // Update is called once per frame
    void Update () {
        cam.targetTexture = objectNormals;
        cam.SetReplacementShader(ObjectNormalsShader, null);
        cam.Render();
        cam.targetTexture = objectDepth;
        cam.SetReplacementShader(ObjectDepthShader, "RenderType");
        cam.Render();
    }
}
