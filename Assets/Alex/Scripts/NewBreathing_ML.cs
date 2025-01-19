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
    private float riseTime = 0f;
    private float fallTime = 0f;
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
        if (curValue > localPeak + threshold && curValue > lastValue && !isRising)
        {
            riseTime = Time.time;
            isRising = true;
            isFalling = false;
            localPeak = curValue;
            Debug.Log("Breathing in");
        }

        else if (curValue < localPeak + threshold && curValue < lastValue && !isFalling)
        {
            fallTime = Time.time;
            isFalling = true;
            isRising = false;
            localPeak = curValue;
            Debug.Log("Breathing out");
        }

        if (isRising && Time.time - riseTime >= inhaleDuration && localPeak >=posPeak)
        {
            Debug.Log($"Inhalation phase completed. Peak reached. Elapsed time: {Time.time - riseTime:F2}s");
            isRising = false;
        }

        if (!exhaleTrigger && Time.time - fallTime >= exhaleDuration / 2)
        {
            exhaleTrigger = true;
            Debug.Log("Trigger activated");
        }

        if (isFalling && Time.time - fallTime >= exhaleDuration && localPeak <= negPeak)
        {
            Debug.Log($"Exhalation phase completed. Peak reached. Elapsed time: {Time.time - fallTime:F2}s");
            cycleCount++;
            isFalling = false;
            exhaleTrigger = false;
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
