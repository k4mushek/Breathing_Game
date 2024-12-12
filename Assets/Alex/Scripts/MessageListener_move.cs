using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MessageListener_move : MonoBehaviour
{
    [SerializeField] private float moveSpeed = 5f;
    private Rigidbody rb;
    private float prevValue = 0;
   
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }
    void OnMessageArrived(string msg)
    {
        Debug.Log("Message arrived: " + msg);

        float curValue = float.Parse(msg);
        if(prevValue < curValue) 
        {
            Debug.Log("inhale");
        }

        else if(prevValue > curValue)
        {
            Debug.Log("exhale");
        }
        prevValue = curValue;
        
    }
    void OnConnectionEvent(bool success)
    {
        if (success)
            Debug.Log("Connection established");
        else
            Debug.Log("Connection attempt failed or disconnection detected");
    }
}
