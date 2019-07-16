using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BufferSelector : MonoBehaviour {

    public CameraRenderScript camScript;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    public void UpdateIndex(int index)
    {
        CameraRenderScript.RenderTarget mode = camScript.mode;

        switch(index)
        {
            case 0:
                {
                    mode = CameraRenderScript.RenderTarget.Final;
                }
                break;

            case 1:
                {
                    mode = CameraRenderScript.RenderTarget.Color;
                }
                break;

            case 2:
                {
                    mode = CameraRenderScript.RenderTarget.Normals;
                }
                break;

            case 3:
                {
                    mode = CameraRenderScript.RenderTarget.Depth;
                }
                break;

            case 4:
                {
                    mode = CameraRenderScript.RenderTarget.Sobel;
                }
                break;

            case 5:
                {
                    mode = CameraRenderScript.RenderTarget.Distortion;
                }
                break;

            case 6:
                {
                    mode = CameraRenderScript.RenderTarget.DepthGradient;
                }
                break;

            case 7:
                {
                    mode = CameraRenderScript.RenderTarget.Final;
                }
                break;
        }
        camScript.mode = mode;
    }
}
