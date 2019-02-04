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
        FirstBlur,
        SecondBlur,
        Thin,
        ObjectNormals,
    }

    public RenderTarget mode = RenderTarget.Final;
    public Material colorMat;
    public Material depthMat;
    public Material normalsMat;
    public Material gaussianProcessMat;
    public Material sobelProcessMat;
    public Material noiseReductionMat;
    public Material thinLinesMat;
    public Material mixTargetsMat;
    public Material finalMat;

    public Shader ToonShader;
    public Texture shadowTexture;

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
    RenderTexture normalsTarget;
    RenderTexture blurNormalsTarget;
    RenderTexture blurColorTarget;
    RenderTexture sobelTargetColor;
    RenderTexture thinLinesTarget;
    RenderTexture noiseReductionTarget;
    RenderTexture blurTarget;
    RenderTexture final;

    public RenderTexture characterNormals;
    public RenderTexture characterDepth;
    public ObjectNormalsRender objNormScript;
    RenderTexture objectNormals;
    RenderTexture objectDepth;

    float timer = 0.0f;
    [Range(10,60)]
    public int frames = 25;

    RenderBuffer[] mrtRB = new RenderBuffer[1];
    void OnEnable()
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

        normalsTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        normalsTarget.Create();

        blurNormalsTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        blurNormalsTarget.Create();

        blurColorTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        blurColorTarget.Create();

        sobelTargetColor = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        sobelTargetColor.Create();

        thinLinesTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        thinLinesTarget.Create();

        noiseReductionTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
        noiseReductionTarget.Create();

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

       // if (timer >= 1.0f / (float)frames)
        {
            timer = 0.0f;

            //Depth Texture-------------------------------------
            Graphics.Blit(source, depthTarget, depthMat);
            //--------------------------------------------------

            //Depth Texture-------------------------------------
            Graphics.Blit(source, colorTarget, colorMat);
            //--------------------------------------------------

            //Normals Texture-------------------------------------
            normalsMat.SetTexture("_CameraDepth", depthTarget);
            normalsMat.SetTexture("_CharactersNormals", characterNormals);
            normalsMat.SetTexture("_MapNormals", objectNormals);
            normalsMat.SetTexture("_CharacterDepth", characterDepth);
            normalsMat.SetTexture("_MapDepth", objectDepth);
            Graphics.Blit(colorTarget, normalsTarget, normalsMat);
            //--------------------------------------------------

            //Remove Noise-------------------------------------
            noiseReductionMat.SetTexture("_CameraDepth", depthTarget);
            noiseReductionMat.SetInt("_UsingDepth", 1);
            Graphics.Blit(normalsTarget, blurNormalsTarget, noiseReductionMat);
            //-------------------------------------------------------

            //Remove Noise-------------------------------------
            noiseReductionMat.SetTexture("_CameraDepth", depthTarget);
            noiseReductionMat.SetInt("_UsingDepth", 1);
            Graphics.Blit(colorTarget, blurColorTarget, noiseReductionMat);
            //-------------------------------------------------------

            //SOBEL--------------------------------------------------
            sobelProcessMat.SetTexture("_CameraDepth", depthTarget);
            sobelProcessMat.SetTexture("_CameraNormals", blurNormalsTarget);
            sobelProcessMat.SetFloat("_ColorWidth", ColWidth);
            sobelProcessMat.SetFloat("_NormalWidth", NormWidth);
            sobelProcessMat.SetFloat("_DepthWidth", DepthWidth);

            sobelProcessMat.SetFloat("_ColThreshold", ColThreshold);
            sobelProcessMat.SetFloat("_NormThreshold", NormThreshold);
            sobelProcessMat.SetFloat("_DepthThreshold", DepthThreshold);
            sobelProcessMat.SetInt("_DistanceFalloff", DistanceFalloff);
            Graphics.Blit(colorTarget, sobelTargetColor, sobelProcessMat);
            //-----------------------------------------------------

            //Remove Noise-------------------------------------
            //noiseReductionMat.SetTexture("_CameraDepth", depthTarget);
            //noiseReductionMat.SetInt("_UsingDepth", 1);
            Graphics.Blit(sobelTargetColor, thinLinesTarget, thinLinesMat);
            //-------------------------------------------------------

            //Remove Noise-------------------------------------
            noiseReductionMat.SetTexture("_CameraDepth", depthTarget);
            noiseReductionMat.SetInt("_UsingDepth", 1);
            Graphics.Blit(thinLinesTarget, noiseReductionTarget, noiseReductionMat);
            //-------------------------------------------------------

            //Final Outline Blur-------------------------------------
            gaussianProcessMat.SetFloat("_Intensity", outlineBlurInt);
            Graphics.Blit(noiseReductionTarget, blurTarget, gaussianProcessMat);
            //-------------------------------------------------------

            //Mix Original Tex + outline ----------------------------
            finalMat.SetTexture("_CameraDepth", depthTarget);
            finalMat.SetTexture("_OutlineTex", blurTarget);
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
                    Graphics.Blit(blurColorTarget, destination);
                    break;
                }
            case RenderTarget.Depth:
                {
                    Graphics.Blit(depthTarget, destination);
                    break;
                }
            case RenderTarget.Thin:
                {
                    Graphics.Blit(thinLinesTarget, destination);
                    break;
                }
            case RenderTarget.Sobel:
                {
                    Graphics.Blit(sobelTargetColor, destination);
                    break;
                }
            case RenderTarget.Normals:
                {
                    Graphics.Blit(blurNormalsTarget, destination);
                    break;
                }
            case RenderTarget.SecondBlur:
                {
                    Graphics.Blit(blurTarget, destination);
                    break;
                }
            case RenderTarget.ObjectNormals:
                {
                    Graphics.Blit(characterNormals, destination);
                    break;
                }
        }
       
    }
    

}
