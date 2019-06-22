using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraSimulation : MonoBehaviour {

    public CPC_CameraPath path;
    bool wantToRestart = false;
    bool readyToStop = false;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if(wantToRestart)
        {
            if (readyToStop)
            {
                path.PausePath();
                wantToRestart = false;
                readyToStop = false;
            }
            else
                readyToStop = true;           
            
        }
	}
    public void PlaySim()
    {
        if(path.IsPlaying())
            path.PausePath();
        else
        {
            if(path.GetCurrentTimeInWaypoint() == 0.0f && path.GetCurrentWayPoint() == 0)
                path.PlayPath(30.0f);
            else
                path.ResumePath();
        }
           
    }

    public void RestartSim()
    {
        //path.PausePath();
        path.SetCurrentWayPoint(0);
        path.SetCurrentTimeInWaypoint(0.0f);
        //path.StopPath();
        wantToRestart = true;
    }
}
