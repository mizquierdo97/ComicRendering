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
        Distortion,
        DepthGradient,
    }


    public RenderTarget mode = RenderTarget.Final;
    public Material colorMat;
    public Material depthMat;
    public Material normalsMat;
    //public Material gaussianProcessMat;
    public Material sobelProcessMat;
    public Material distortionMat;
    public Material noiseReductionMat;
    public Material thinLinesMat;
    public Material mixTargetsMat;
    public Material finalMat;

    public Color outlineColor;

    public Texture noiseTexture;
    public Texture brushesTexture;
    public float Intensity; 
    public float IntensityHigh;


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

    public float outlineBlurInt = 1.0f;

    //RENDER TARGETS
    RenderTexture depthTarget;
    RenderTexture colorTarget;
    RenderTexture colorDistTargetPrev;
    RenderTexture colorDistTargetPrev2;
    RenderTexture colorDistTargetPrev3;
    RenderTexture colorDistTarget;
    RenderTexture normalsTarget;
    RenderTexture blurNormalsTarget;
    RenderTexture blurColorTarget;
    RenderTexture sobelTargetColor;
    RenderTexture distortionTarget;
    RenderTexture blurTarget;
    RenderTexture final;

    public RenderTexture objectNormals;
    public RenderTexture objectDepth;
    public RenderTexture charactersNormals;
    public RenderTexture charactersDepth;
    public RenderTexture worldPosTexture;

    public Shader MapNormals;
    public Shader MapDepth;
    public Shader CharactersNormals;
    public Shader CharactersDepth;
    public Shader WorldPositionShader;

    float timer = 0.0f;
    [Range(10, 60)]
    public int frames = 25;

    //Cameras 
    private Camera Cam
    {
        get { return GetComponent<Camera>(); }
    }
    private Camera charactersCamera;
    private GameObject charactersCameraObject;


    private GameObject CharactersCameraObject
    {

        get
        {
            if (!charactersCameraObject)
            {
                charactersCameraObject = new GameObject("selectiveGlowCameraObject");
                charactersCameraObject.AddComponent<Camera>();
                charactersCameraObject.hideFlags = HideFlags.HideAndDontSave;
                CharactersCamera.orthographic = false;
                CharactersCamera.enabled = false;
                CharactersCamera.renderingPath = RenderingPath.VertexLit;
                CharactersCamera.hideFlags = HideFlags.HideAndDontSave;
            }
            return charactersCameraObject;
        }
    }
    private Camera CharactersCamera
    {
        get
        {
            if (charactersCamera == null)
            {
                charactersCamera = CharactersCameraObject.GetComponent<Camera>();
            }
            return charactersCamera;
        }
    }

    private void SetupGlowCamera(RenderTexture render, LayerMask layer)
    {
        CharactersCamera.CopyFrom(Cam);
        CharactersCamera.depthTextureMode = DepthTextureMode.None;
        CharactersCamera.targetTexture = render;

        CharactersCamera.clearFlags = CameraClearFlags.SolidColor;
        CharactersCamera.rect = new Rect(0, 0, 1, 1);
        CharactersCamera.backgroundColor = new Color(0, 0, 0, 0);
        CharactersCamera.cullingMask = layer;
        CharactersCamera.renderingPath = RenderingPath.VertexLit;
    }

    void OnEnable()
    { 
    }
    void Start()
    { 
        Camera camera = GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.DepthNormals;
        camera.depthTextureMode |= DepthTextureMode.Depth;

        int width = Screen.width * 2;
        int height = Screen.height * 2;

        charactersNormals = new RenderTexture(width, height, 16, RenderTextureFormat.ARGBFloat);
        charactersDepth = new RenderTexture(width, height, 32, RenderTextureFormat.RFloat);
        objectNormals = new RenderTexture(width, height, 32, RenderTextureFormat.ARGBFloat);
        objectDepth = new RenderTexture(width, height, 32, RenderTextureFormat.RFloat);
        worldPosTexture = new RenderTexture(width, height, 32, RenderTextureFormat.ARGBFloat);

        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.DepthNormals;
        cam.depthTextureMode |= DepthTextureMode.Depth;


        depthTarget = new RenderTexture(width, height, 32, RenderTextureFormat.RFloat);
        depthTarget.Create();

        colorTarget = new RenderTexture(width, height, 16, RenderTextureFormat.ARGBFloat);
        colorTarget.Create();

        colorDistTargetPrev = new RenderTexture(width, height, 16, RenderTextureFormat.ARGBFloat);
        colorDistTargetPrev.Create();

        colorDistTargetPrev2 = new RenderTexture(width, height, 16, RenderTextureFormat.ARGBFloat);
        colorDistTargetPrev2.Create();

        colorDistTargetPrev3 = new RenderTexture(width, height, 16, RenderTextureFormat.ARGBFloat);
        colorDistTargetPrev3.Create();

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

        //objectNormals = objNormScript.objectNormals;
        //objectDepth = objNormScript.objectDepth;
    }
  
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        timer += Time.deltaTime;
        if (timer >= 1.0f / (float)frames)
        {

            SetupGlowCamera(objectNormals, LayerMask.GetMask("Map"));
            CharactersCamera.RenderWithShader(MapNormals, "RenderType");
            SetupGlowCamera(objectDepth, LayerMask.GetMask("Map"));
            CharactersCamera.RenderWithShader(MapDepth, "RenderType");
            SetupGlowCamera(charactersNormals, LayerMask.GetMask("Characters"));
            CharactersCamera.RenderWithShader(CharactersNormals, "RenderType");
            SetupGlowCamera(charactersDepth, LayerMask.GetMask("Characters"));
            CharactersCamera.RenderWithShader(CharactersDepth, "RenderType");
            SetupGlowCamera(worldPosTexture, LayerMask.GetMask("Map", "Characters"));
            CharactersCamera.RenderWithShader(WorldPositionShader, "RenderType");
            timer = 0.0f;

            //Depth Texture-------------------------------------
            Graphics.Blit(source, depthTarget, depthMat);
            //--------------------------------------------------

            //Color Texture-------------------------------------
            Graphics.Blit(source, colorTarget, colorMat);
            //--------------------------------------------------

            //Distortion
            distortionMat.SetFloat("_Intensity", Intensity);
            distortionMat.SetInt("_Type", 0);
            distortionMat.SetTexture("_WorldPosTex", worldPosTexture);
            distortionMat.SetTexture("_DistortionTexture", brushesTexture);
            distortionMat.SetTexture("_CameraDepth", depthTarget);
            Graphics.Blit(colorTarget, colorDistTargetPrev, distortionMat);

            distortionMat.SetFloat("_Intensity", Intensity);
            distortionMat.SetInt("_Type", 2);
            distortionMat.SetTexture("_WorldPosTex", worldPosTexture);
            distortionMat.SetTexture("_DistortionTexture", brushesTexture);
            distortionMat.SetTexture("_CameraDepth", depthTarget);
            Graphics.Blit(colorDistTargetPrev, colorDistTargetPrev2, distortionMat);

            distortionMat.SetFloat("_Intensity", Intensity);
            distortionMat.SetInt("_Type", 3);
            distortionMat.SetTexture("_WorldPosTex", worldPosTexture);
            distortionMat.SetTexture("_DistortionTexture", brushesTexture);
            distortionMat.SetTexture("_CameraDepth", depthTarget);
            Graphics.Blit(colorDistTargetPrev2, colorDistTargetPrev3, distortionMat);

            distortionMat.SetFloat("_Intensity", IntensityHigh);
            distortionMat.SetInt("_Type", 1);
            distortionMat.SetTexture("_WorldPosTex", worldPosTexture);
            distortionMat.SetTexture("_DistortionTexture", brushesTexture);
            distortionMat.SetTexture("_CameraDepth", depthTarget);
            Graphics.Blit(colorDistTargetPrev3, colorDistTarget, distortionMat);
            //

            //blur
            // gaussianProcessMat.SetTexture("_CameraDepth", depthTarget);
            // gaussianProcessMat.SetFloat("_Intensity", outlineBlurInt);
            // Graphics.Blit(colorDistTarget, blurColorTarget, gaussianProcessMat);
            //

            //Normals Texture-------------------------------------
            normalsMat.SetTexture("_CameraDepth", depthTarget);
            normalsMat.SetTexture("_CharactersNormals", charactersNormals);
            normalsMat.SetTexture("_MapNormals", objectNormals);
            normalsMat.SetTexture("_CharacterDepth", charactersDepth);
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
            distortionMat.SetTexture("_BrushesTexture", brushesTexture);
            Graphics.Blit(sobelTargetColor, distortionTarget, distortionMat);
            //

            //Mix Original Tex + outline ----------------------------
            finalMat.SetTexture("_CameraDepth", depthTarget);
            finalMat.SetTexture("_OutlineTex", distortionTarget);
            finalMat.SetColor("_OutlineColor", outlineColor);
            Graphics.Blit(colorDistTarget, final, finalMat);
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
            case RenderTarget.Distortion:
                {
                    Graphics.Blit(distortionTarget, destination);
                    break;
                }
            case RenderTarget.DepthGradient:
                {
                    Graphics.Blit(distortionTarget, destination);
                    break;
                }
        }
    }
}
