using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;

public class Calibration_ML : MonoBehaviour
{
    // Start is called before the first frame update
    public TextMeshProUGUI inhaleExhaleText;
    static public int minPeak;
    static public int maxPeak;
    [SerializeField] private int callibration;
    [SerializeField] private int targetCycles = 10;
    [SerializeField] private float inhaleDuration = 3f;
    [SerializeField] private float exhaleDuration = 3f;

    public string nextSceneName = "L_TestingVR";

    private int prevValue = 0;
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

        int curValue = int.Parse(msg);

        if (curValue > prevValue + callibration)
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

        else if (curValue < prevValue + callibration)
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
    }
    void LoadNextScene()
    {
        SceneManager.LoadScene(nextSceneName);
    }

    public void SetInt(string name, int value)
        {
            PlayerPrefs.SetInt("NegPeak", minPeak);
            PlayerPrefs.SetInt("PosPeak", maxPeak);
        }
}