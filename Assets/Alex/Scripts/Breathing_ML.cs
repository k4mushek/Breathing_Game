using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using TMPro;
using UnityEngine;
using Debug = UnityEngine.Debug;

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
    [SerializeField] private GameObject leaf;
    [SerializeField] private Camera playerCamera;

    private float posPeak = Calibration_ML.maxPeak;
    private float negPeak = Calibration_ML.minPeak;
    private int localPosPeak;
    private int localNegPeak;
    private int cycleCount = 0;
    private int targetCycles = 1;
    private int currentPhase = 0;
    private float prevValue = 0f;
    private bool isRising = false;
    private bool isFalling = false;
    private bool canGrow = false;
    private bool animationInProgress = false;
    private float phaseTimer = 0f;
    private Animator growing;

    public TextMeshProUGUI inhaleExhaleText;

    void Start()
    {
        Debug.Log("PosPeak= " + Calibration_ML.maxPeak);
        Debug.Log("NegPeak= " + Calibration_ML.minPeak);
        growing = scaleObject.GetComponent<Animator>();
        if (inhaleExhaleText != null)
        {
            inhaleExhaleText.text = "Inhale";
        }
    }
    void OnMessageArrived(string msg)
    {
        int curValue = int.Parse(msg);

       // if (isRising || isFalling)
       // {
       //     phaseTimer = Time.time;
       // }

       // Stopwatch.text = "Time: " +phaseTimer.ToString("F2") + "s";

        if (curValue > prevValue + callibration)
        {
            localPosPeak = curValue;

            if (!isRising)
            {
                riseTime = Time.time;
                isRising = true;
                isFalling = false;
                Debug.Log("Inhale");
                Debug.Log(posPeak * peakCalibration - localPosPeak);

                if (inhaleExhaleText != null)
                {
                    inhaleExhaleText.text = "Inhale";
                }
            }

            if (Time.time - riseTime >= inhaleDuration)
            {
                isRising = false;
                isFalling = true;
                canGrow = true;
                fallTime = Time.time;

                if (localPosPeak + peakCalibration >= posPeak)
                {
                    Debug.Log("Reached peak");

                    if (inhaleExhaleText != null)
                    {
                        inhaleExhaleText.text = "Exhale";
                    }
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
                Debug.Log("Exhale");

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
                }
            }
        }
        prevValue = curValue;

        if (!animationInProgress && currentPhase < 4)
        {
            growing.SetTrigger($"Phase{currentPhase + 1}");
            animationInProgress = true;
            Debug.Log($"Starting Phase {currentPhase + 1}");
        }
    }

    public void OnAnimationComplete()
    {
        animationInProgress = false;
        currentPhase++;

        if (currentPhase == 4)
        {
            SpawnLeaf();
            CameraToLeaf();
        }
    }

    void SpawnLeaf()
    {
        Vector3 spawnPosition = new Vector3(0f, 1f, 0f);
        Instantiate(leaf, spawnPosition, Quaternion.identity);
        Debug.Log("Leaf is spawned");
    }

    void CameraToLeaf()
    {
        GameObject spawnedObject = Instantiate(leaf);
        playerCamera.transform.position = new Vector3(spawnedObject.transform.position.x, spawnedObject.transform.position.y, playerCamera.transform.position.z);
        playerCamera.transform.LookAt(spawnedObject.transform);  // Focus the camera on the new object
        Debug.Log("Camera moved to leaf");
    }

    public void OnCycleComplete()
    {
        if (currentPhase < 4)
        {
            growing.SetTrigger($"Phase{currentPhase + 1}");
            animationInProgress = true;
            Debug.Log($"Starting Phase {currentPhase + 1}");
        }
    }
}
