using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CharacterCameraScript : MonoBehaviour {

	
    public enum RenderTarget
    {
        Final = 0,
        Color = 1,
        Depth,
        Normals,
        Sobel,
        FirstBlur,
        SecondBlur,
        Thin,
        ObjectNormals,
    }

    public RenderTarget mode = RenderTarget.Final;
    public Material normalsMat;
    public Material depthMat;

    public Shader ToonShader;
    public Texture shadowTexture;

    public Color lineColor;
    public Camera cam;
    public float ColWidth = 0.001f;
    public float NormWidth = 0.001f;
    public float DepthWidth = 0.001f;


    public RenderTexture normalsTarget;
    public RenderTexture depthTarget;

    void OnEnable()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.DepthNormals;
        int width = Screen.width * 2;
        int height = Screen.height * 2;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //Normals Texture-------------------------------------
        Graphics.Blit(source, destination, normalsMat);
        //--------------------------------------------------
        //Normals Texture-------------------------------------
        Graphics.Blit(source, depthTarget, depthMat);
        //--------------------------------------------------
    }

}
