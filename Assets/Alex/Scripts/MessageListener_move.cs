using Meta.XR.ImmersiveDebugger.UserInterface;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class MessageListener_move : MonoBehaviour
{
    [SerializeField] private GameObject scaleObject;
    [SerializeField] private float ScaleFactor;
    [SerializeField] private float callibration;
    [SerializeField] private float dropThreshold = 0.7f;
    private float prevValue = 0;
    private float peak = 0f;
    private bool canGrow = true;

   // public int Getint(string Name)
    //{
    //    return PlayerPrefs.GetInt("NegPeak");
    //}
    void Start()
    {
        //rb = GetComponent<Rigidbody>();
    }
    void OnMessageArrived(string msg)
    {
        Debug.Log("Message arrived: " + msg);

        float curValue = float.Parse(msg);

        if (curValue > prevValue + callibration) 
        {
            Debug.Log("inhale");
           
            if (curValue > peak)
            {
                peak = curValue;
            }
        }

        else if(curValue < peak + callibration)
        {
            Debug.Log("exhale");
        }

        if (curValue < peak * dropThreshold && canGrow)
        {
            //float scale = curValue / deScaleFactor;
            //Debug.Log(scale);
            scaleObject.transform.localScale = new Vector3(ScaleFactor, ScaleFactor, ScaleFactor);
            prevValue = curValue;
        }
    }

    void OnConnectionEvent(bool success)
    {
        if (success)
            Debug.Log("Connection established");
        else
            Debug.Log("Connection attempt failed or disconnection detected");
    }
}
