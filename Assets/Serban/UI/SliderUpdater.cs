using UnityEngine;
using UnityEngine.UI;

public class SliderUpdater : MonoBehaviour
{
    [SerializeField] private Image breathingImage; // Reference to the Image component
    private Calibration_ML breathingML; // Reference to Breathing_ML, will be found at runtime

    private float smoothTime = 0.3f; // Smoothing time for the transition
    private float currentFillAmount = 0f; // Current fill amount for smooth transition
    private float targetFillAmount = 0f; // The target fill amount to match

    void Start()
    {
        // Automatically find the Breathing_ML component at runtime
        breathingML = FindObjectOfType<Calibration_ML>();

        if (breathingML == null)
        {
            Debug.LogError("Breathing_ML component not found in the scene!");
        }

        if (breathingImage != null)
        {
            breathingImage.fillAmount = 0f; // Initialize the fill amount to 0 (empty)
        }
    }

    void Update()
    {
        if (breathingML != null)
        {
            //Read the TargetSliderValue from Breathing_ML and update the fillAmount of the Image;
            targetFillAmount = breathingML.TargetSliderValue;
        }

        // Smoothly update the fill amount of the image
        if (breathingImage != null)
        {
            currentFillAmount = Mathf.SmoothDamp(currentFillAmount, targetFillAmount, ref smoothTime, 0.3f);
            breathingImage.fillAmount = currentFillAmount;
        }
    }
}
