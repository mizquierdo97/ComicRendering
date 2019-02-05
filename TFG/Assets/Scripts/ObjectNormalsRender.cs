using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectNormalsRender : MonoBehaviour
{

    Camera cam;
    public RenderTexture objectNormals;
    public RenderTexture objectDepth;
    public Shader ObjectNormalsShader;
    public Shader ObjectDepthShader;
    public Material ObjectDepthMat;
    // Use this for initialization
    void OnEnable()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.DepthNormals;
        cam.depthTextureMode |= DepthTextureMode.Depth;

        cam.targetTexture = objectNormals;
        cam.SetReplacementShader(ObjectNormalsShader, null);

        GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
        cam.targetTexture = objectNormals;
        cam.SetReplacementShader(ObjectNormalsShader, null);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, objectDepth, ObjectDepthMat);
        Graphics.Blit(source, destination);
    }
}
