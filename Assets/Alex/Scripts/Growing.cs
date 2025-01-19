using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Growing : MonoBehaviour
{
    public GameObject growingTree;
    public GameObject leaf;
    public Camera playerCamera;
    private Animator treeAnimator;
    private int currentPhase = 0;
    private bool animationInProgress = false;

    private NewBreathing_ML breathingScript;
    void Start()
    {
        treeAnimator = growingTree.GetComponent<Animator>();
        breathingScript = FindObjectOfType<NewBreathing_ML>();
    }

    void Update()
    {
        if (breathingScript != null && breathingScript.exhaleTrigger)
        {
            breathingScript.exhaleTrigger = false;
            StartAnimation();
        }
    }

    void StartAnimation()
    {
        if (!animationInProgress)
        {
            animationInProgress = true;
            currentPhase = 0;
            treeAnimator.SetTrigger($"Phase{currentPhase + 1}");
            Debug.Log("Starting animation...");
        }
    }

    public void OnAnimationComplete()
    {
        // Move to the next phase
        currentPhase++;

        // Check if we have completed all phases
        if (currentPhase >= 4)
        {
            Debug.Log("All phases completed.");
            SpawnLeaf();
            MoveCameraToLeaf();
            currentPhase = 0;
            breathingScript.exhaleTrigger = false;
        }
        else
        {
            treeAnimator.SetTrigger($"Phase{currentPhase + 1}");
        }

        animationInProgress = false;
    }

    void SpawnLeaf()
    {
        Vector3 spawnPosition = new Vector3(0f, 1f, 0f);
        Instantiate(leaf, spawnPosition, Quaternion.identity);
        Debug.Log("Leaf is spawned");
    }

    void MoveCameraToLeaf()
    {
        GameObject spawnedLeaf = Instantiate(leaf);
        playerCamera.transform.position = new Vector3(spawnedLeaf.transform.position.x, spawnedLeaf.transform.position.y, spawnedLeaf.transform.position.z);
        playerCamera.transform.LookAt(spawnedLeaf.transform);
    }
}
