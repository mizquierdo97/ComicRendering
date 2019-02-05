using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CharacterCameraScript : MonoBehaviour
{

    public Material normalsMat;
    public Material depthMat;

    public Shader ToonShader;
    public Texture shadowTexture;

    public Camera cam;

    public RenderTexture normalsTarget;
    public RenderTexture depthTarget;

    void OnEnable()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.DepthNormals;
        int width = Screen.width;
        int height = Screen.height;

        normalsTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGBFloat);
        cam.targetTexture = normalsTarget;

        depthTarget = new RenderTexture(width, height, 32, RenderTextureFormat.RFloat);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //Normals Texture-------------------------------------
        Graphics.Blit(source, destination, normalsMat);
        //--------------------------------------------------
        //Depth Texture-------------------------------------
        Graphics.Blit(source, depthTarget, depthMat);
        //--------------------------------------------------
    }

}
