using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class Breathing_ML : MonoBehaviour
{
    [SerializeField] private float inhaleDuration = 3f;
    [SerializeField] private float exhaleDuration = 3f;
    [SerializeField] private int callibration;
    [SerializeField] private float peakCalibration = 0.05f;
    [SerializeField] private float riseTime = 0f;
    [SerializeField] private float fallTime = 0f;
    [SerializeField] private float dropThreshold = 0.7f;
    [SerializeField] private float ScaleFactor;
    [SerializeField] private GameObject scaleObject;

    private int posPeak = Calibration_ML.maxPeak;
    private int negPeak = Calibration_ML.minPeak;
    private int localPosPeak;
    private int localNegPeak;
    private int prevValue = 0;
    private bool isRising = false;
    private bool isFalling = false;
    private bool canGrow = false;

    public TextMeshProUGUI inhaleExhaleText;

    void Start()
    {
        Debug.Log("PosPeak= " + Calibration_ML.maxPeak);
        Debug.Log("NegPeak= " + Calibration_ML.minPeak);
        if (inhaleExhaleText != null)
        {
            inhaleExhaleText.text = "Inhale";
        }
    }
    void OnMessageArrived(string msg)
    {
        int curValue = int.Parse(msg);

        if (curValue > prevValue + callibration)
        {
            localPosPeak = curValue;

            if (!isRising)
            {
                riseTime = Time.time;
                isRising = true;
                isFalling = false;

                if (inhaleExhaleText != null)
                {
                    inhaleExhaleText.text = "Inhale";
                }
            }

            if ((localPosPeak >= posPeak + peakCalibration) && (Time.time - riseTime >= inhaleDuration))
            {
                isRising = false;
                isFalling = true;
                canGrow = true;
                fallTime = Time.time;
                Debug.Log("Reached peak");

                if (inhaleExhaleText != null)
                {
                    inhaleExhaleText.text = "Exhale";
                }
            }
        }

        else if (curValue < prevValue + callibration)
        {
            localNegPeak = curValue;

            if (!isFalling)
            {
                fallTime = Time.time;
                isRising = false;
                isFalling = true;

                if (inhaleExhaleText != null)
                {
                    inhaleExhaleText.text = "Exhale";
                }
            }

            if (curValue < posPeak * dropThreshold && canGrow)
            {
                scaleObject.transform.localScale = new Vector3(ScaleFactor, ScaleFactor, ScaleFactor);
                Debug.Log("Scaled!");
                canGrow = false;
            }

            if (Time.time - fallTime >= exhaleDuration)
            {
                isRising = true;
                isFalling = false;
                riseTime = Time.time;

                if (inhaleExhaleText != null)
                {
                    inhaleExhaleText.text = "Inhale";
                }
            }

            prevValue = curValue;
        }
    }
}
