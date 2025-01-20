using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;

public class Calibration_ML : MonoBehaviour
{
    // Start is called before the first frame update
    public TextMeshProUGUI inhaleExhaleText;
    static public float minPeak;
    static public float maxPeak;
    private float peakRange;
    private float threshold;
    [SerializeField] private int targetCycles = 10;
    [SerializeField] private float inhaleDuration = 3f;
    [SerializeField] private float exhaleDuration = 3f;

    public string nextSceneName = "L_TestingVR";

    private float prevValue = 0;
    private int cycleCount = 0;
    private bool isRising = false;
    private bool isFalling = false;
    [SerializeField] private float riseTime = 0f;
    [SerializeField] private float fallTime = 0f;

    private void Start()
    {
        if (inhaleExhaleText != null)
        {
            inhaleExhaleText.text = "Inhale";
        }
    }
    void OnMessageArrived(string msg)
    {
        //Debug.Log("Message arrived: " + msg);

        float curValue = float.Parse(msg);

        if (curValue > prevValue + threshold)
        {
            maxPeak = curValue;
            Debug.Log("New Max Peak: " + maxPeak);

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

            if (Time.time - riseTime >= inhaleDuration)
            {
                isRising = false; 
                isFalling = true;
                fallTime = Time.time;

                if (inhaleExhaleText != null)
                {
                    inhaleExhaleText.text = "Exhale";
                }
            }
        }

        else if (curValue < prevValue + threshold)
        {
            minPeak = curValue;
            Debug.Log("New Min Peak: " + minPeak);

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

            if (Time.time - fallTime >= exhaleDuration)
            {
                isRising = true;
                isFalling = false;
                riseTime = Time.time;

                if (inhaleExhaleText != null)
                {
                    inhaleExhaleText.text = "Inhale";
                }

                cycleCount++;

                if (cycleCount >= targetCycles)
                {
                    cycleCount = 0;
                    Debug.Log("Completed");

                    LoadNextScene();
                }
            }

        }
        
        prevValue = curValue;
        peakRange = maxPeak - minPeak;
        threshold = peakRange * 0.1f;
    }
    void LoadNextScene()
    {
        SceneManager.LoadScene(nextSceneName);
    }

    void OnConnectionEvent(bool success)
    {
        if (success)
            Debug.Log("Connection established");
        else
            Debug.Log("Connection attempt failed or disconnection detected");
    }
}