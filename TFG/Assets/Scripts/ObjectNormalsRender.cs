using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectNormalsRender : MonoBehaviour
{

    Camera cam;
    public RenderTexture objectNormals;
    public RenderTexture objectDepth;
    public Shader ObjectNormalsShader;
    public Material ObjectDepthMat;

    void OnEnable()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.DepthNormals;
        cam.depthTextureMode |= DepthTextureMode.Depth;

        int width = Screen.width * 1;
        int height = Screen.height * 1;

        objectNormals = new RenderTexture(width, height, 32, RenderTextureFormat.ARGBFloat);
        objectDepth = new RenderTexture(width, height, 32, RenderTextureFormat.RFloat);

        cam.targetTexture = objectNormals;
        cam.SetReplacementShader(ObjectNormalsShader, null);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, objectDepth, ObjectDepthMat);
        Graphics.Blit(source, destination);
    }
}
