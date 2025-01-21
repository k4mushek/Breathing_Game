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
        leaf.GetComponent<MeshRenderer>().enabled = false;
        breathingScript = FindObjectOfType<NewBreathing_ML>();
    }

    void Update()
    {
        if (breathingScript.exhaleTrigger)
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
            OnAnimationComplete();
        }
    }

    public void OnAnimationComplete()
    {
        currentPhase++;

        if (currentPhase >= 4)
        {
            Debug.Log("All phases completed.");
            SpawnLeaf();
            MoveCameraToLeaf();
            currentPhase = 0;
            breathingScript.exhaleTrigger = false;

            StopAnimation();
        }
        else
        {
            treeAnimator.SetTrigger($"Phase{currentPhase + 1}");
        }

        animationInProgress = false;
    }

    void StopAnimation()
    {
        treeAnimator.speed = 0; 
    }

        void SpawnLeaf()
    {
        leaf.GetComponent<MeshRenderer>().enabled = true;
        Debug.Log("Leaf is spawned");
    }

    void MoveCameraToLeaf()
    {
        Vector3 targetPosition = leaf.transform.position;
        float moveSpeed = 5f;
        playerCamera.transform.position = Vector3.MoveTowards(playerCamera.transform.position, targetPosition, moveSpeed * Time.deltaTime);
        playerCamera.transform.LookAt(leaf.transform);
    }
}
