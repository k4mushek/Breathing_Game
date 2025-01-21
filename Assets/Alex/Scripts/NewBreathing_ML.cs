using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBreathing_ML : MonoBehaviour
{
    private float posPeak = Calibration_ML.maxPeak;
    private float negPeak = Calibration_ML.minPeak;

    [SerializeField] private float inhaleDuration = 3f;
    [SerializeField] private float exhaleDuration = 3f;

    private float peakRange;
    private float threshold;
    [SerializeField] private float riseTime = 0f;
    [SerializeField] private float fallTime = 0f;
    private float lastValue = 0f;
    private float localPeak = 0f;
    private bool isRising = false;
    private bool isFalling = false;
    private int cycleCount = 0;
    private int targetCycles = 1;

    public bool exhaleTrigger = false;

    void Start()
    {
        Debug.Log("PosPeak= " + posPeak);
        Debug.Log("NegPeak= " + negPeak);
        peakRange = posPeak - negPeak;
        threshold = peakRange * 0.1f;
    }

    void OnMessageArrived(string msg)
    {
        //Debug.Log("Message arrived: " + msg);

        float curValue = float.Parse(msg);
        if (curValue > localPeak + threshold && !isRising)
        {
           // riseTime = Time.time;
            isRising = true;
            isFalling = false;
            localPeak = curValue;
            exhaleTrigger = false;
            Debug.Log("Breathing in");

            if (localPeak + threshold >= posPeak)
            {
                Debug.Log("Inhalation peak reached.");
                isRising = false;
            }

            //if (Time.time - riseTime >= inhaleDuration)
            // {

            //}
        }

        else if (curValue < localPeak + threshold && !isFalling)
        {
           // fallTime = Time.time;
            isFalling = true;
            isRising = false;
            localPeak = curValue;
            exhaleTrigger = true;
            Debug.Log("Breathing out");

            //if (exhaleTrigger! && curValue < negPeak + 100f)
            //{
            //    exhaleTrigger = true;
            //    Debug.Log("Trigger activated");
            //}

            if (localPeak - threshold <= negPeak)
            {
                Debug.Log("Exhalation Peak reached");
                cycleCount++;
                isFalling = false;
                
            }

            // if (Time.time - fallTime >= exhaleDuration)
            // {
        }

        

        if (cycleCount >= targetCycles)
        {
            cycleCount = 0;
            Debug.Log("Cycle completed action proceed");
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
