using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [SerializeField] private float moveSpeed = 5f;
    [SerializeField] private float gravity = 9.8f;

    private Rigidbody rb;
    // Start is called before the first frame update
    void Start()
    {
      rb = GetComponent<Rigidbody>();  
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 moveDirection = Vector3.zero;
        if (Input.GetKey(KeyCode.W))
        {
            moveDirection = new Vector3(1, 1, 0);
        }
        else if (Input.GetKey(KeyCode.S))
        {
            moveDirection = new Vector3(1, -1, 0);
        }
        else
        {
            moveDirection = new Vector3(1, -0.2f, 0);
        }

        moveDirection.Normalize();

        rb.velocity = new Vector3(moveDirection.x * moveSpeed, moveDirection.y * moveSpeed, rb.velocity.z);
    }
}
