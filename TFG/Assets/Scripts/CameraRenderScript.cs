using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class CameraRenderScript : MonoBehaviour
{

    public enum RenderTarget
    {
        Final = 0,
        Color = 1,
        Depth,
        Normals,
        Sobel,
        LineBlur,
        ObjectNormals,
    }

    public RenderTarget mode = RenderTarget.Final;
    public Material colorMat;
    public Material depthMat;
    public Material normalsMat;
    public Material gaussianProcessMat;
    public Material sobelProcessMat;
    public Material distortionMat;
    public Material noiseReductionMat;
    public Material thinLinesMat;
    public Material mixTargetsMat;
    public Material finalMat;

    public Shader ToonShader;
    public Texture shadowTexture;
    public Texture noiseTexture;

    public Color lineColor;
    public Camera cam;
    public float ColWidth = 0.001f;
    public float NormWidth = 0.001f;
    public float DepthWidth = 0.001f;


    [Range(0,1)]
    public float ColThreshold = 0.01f;
    [Range(0, 1)]
    public float NormThreshold = 0.01f;
    [Range(0, 1)]
    public float DepthThreshold = 0.01f;
    [Range(0, 20)]
    public int DistanceFalloff = 1;

    public float imageBlurInt = 1.0f;
    public float outlineBlurInt = 1.0f;


    RenderTexture depthTarget;
    RenderTexture colorTarget;
    RenderTexture colorDistTarget;
    RenderTexture normalsTarget;
    RenderTexture blurNormalsTarget;
    RenderTexture blurColorTarget;
    RenderTexture sobelTargetColor;
    RenderTexture distortionTarget;
    RenderTexture blurTarget;
    RenderTexture final;

    public CharacterCameraScript charCameraScript;
    public ObjectNormalsRender objNormScript;
    RenderTexture objectNormals;
    RenderTexture objectDepth;

    float timer = 0.0f;
    [Range(10,60)]
    public int frames = 25;

    RenderBuffer[] mrtRB = new RenderBuffer[1];
    void Start()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.DepthNormals;
        cam.depthTextureMode |= DepthTextureMode.Depth;
        int width = Screen.width * 2;
        int height = Screen.height * 2;


        depthTarget = new RenderTexture(width, height, 32, RenderTextureFormat.RFloat);
        depthTarget.Create();

        colorTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGBFloat);
        colorTarget.Create();

        colorDistTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGBFloat);
        colorDistTarget.Create();

        normalsTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        normalsTarget.Create();

        blurNormalsTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        blurNormalsTarget.Create();

        blurColorTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        blurColorTarget.Create();

        sobelTargetColor = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        sobelTargetColor.Create();

        distortionTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        distortionTarget.Create();

        blurTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        blurTarget.Create();

        final = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        final.Create();

        objectNormals = objNormScript.objectNormals;
        objectDepth = objNormScript.objectDepth;

    }
  
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        timer += Time.deltaTime;
        Shader.SetGlobalTexture("_ShadowTexture", shadowTexture);
        if (timer >= 1.0f / (float)frames)
        {
            timer = 0.0f;

            //Depth Texture-------------------------------------
            Graphics.Blit(source, depthTarget, depthMat);
            //--------------------------------------------------

            //Depth Texture-------------------------------------
            Graphics.Blit(source, colorTarget, colorMat);
            //--------------------------------------------------

            //Distortion
            distortionMat.SetInt("_Type", 0);
            distortionMat.SetTexture("_DistortionTexture", noiseTexture);
            distortionMat.SetTexture("_CameraDepth", depthTarget);
            Graphics.Blit(colorTarget, colorDistTarget, distortionMat);
            //

            //blur
            gaussianProcessMat.SetTexture("_CameraDepth", depthTarget);
            gaussianProcessMat.SetFloat("_Intensity", outlineBlurInt);
            Graphics.Blit(colorDistTarget, blurColorTarget, gaussianProcessMat);

            //

            //Normals Texture-------------------------------------
            normalsMat.SetTexture("_CameraDepth", depthTarget);
            normalsMat.SetTexture("_CharactersNormals", charCameraScript.normalsTarget);
            normalsMat.SetTexture("_MapNormals", objectNormals);
            normalsMat.SetTexture("_CharacterDepth", charCameraScript.depthTarget);
            normalsMat.SetTexture("_MapDepth", objectDepth);
            Graphics.Blit(colorDistTarget, normalsTarget, normalsMat);
            //--------------------------------------------------

            //SOBEL--------------------------------------------------
            sobelProcessMat.SetTexture("_CameraDepth", depthTarget);
            sobelProcessMat.SetTexture("_CameraNormals", normalsTarget);
            sobelProcessMat.SetFloat("_ColorWidth", ColWidth);
            sobelProcessMat.SetFloat("_NormalWidth", NormWidth);
            sobelProcessMat.SetFloat("_DepthWidth", DepthWidth);

            sobelProcessMat.SetFloat("_ColThreshold", ColThreshold);
            sobelProcessMat.SetFloat("_NormThreshold", NormThreshold);
            sobelProcessMat.SetFloat("_DepthThreshold", DepthThreshold);
            sobelProcessMat.SetInt("_DistanceFalloff", DistanceFalloff);
            Graphics.Blit(colorDistTarget, sobelTargetColor, sobelProcessMat);
            //-----------------------------------------------------

            //Distortion

            distortionMat.SetInt("_Type", 1);
            distortionMat.SetTexture("_DistortionTexture", noiseTexture);
            distortionMat.SetTexture("_CameraDepth", depthTarget);
            Graphics.Blit(sobelTargetColor, distortionTarget, distortionMat);


            //
           
            //Mix Original Tex + outline ----------------------------
            finalMat.SetTexture("_CameraDepth", depthTarget);
            finalMat.SetTexture("_OutlineTex", distortionTarget);
            finalMat.SetColor("_OutlineColor", lineColor);
            Graphics.Blit(blurColorTarget, final, finalMat);
            //-------------------------------------------------------
        }
        switch (mode)
        {
            case RenderTarget.Final:
                {
                    Graphics.Blit(final, destination);
                    break;
                }
            case RenderTarget.Color:
                {
                    Graphics.Blit(colorDistTarget, destination);
                    break;
                }
            case RenderTarget.Depth:
                {
                    Graphics.Blit(depthTarget, destination);
                    break;
                }
            case RenderTarget.Sobel:
                {
                    Graphics.Blit(sobelTargetColor, destination);
                    break;
                }
            case RenderTarget.Normals:
                {
                    Graphics.Blit(normalsTarget, destination);
                    break;
                }
            case RenderTarget.ObjectNormals:
                {
                    Graphics.Blit(objectNormals, destination);
                    break;
                }
        }       
    }
}
