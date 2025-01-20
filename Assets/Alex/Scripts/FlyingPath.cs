using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlyingPath : MonoBehaviour
{
    public Transform[] pathPoints;  
    public float moveSpeed = 5f;
    public Camera playerCamera; 
    private float t = 0f;             

    // Update is called once per frame
    void Update()
    {
        if (pathPoints.Length < 2)
            return;

        t += Time.deltaTime * moveSpeed / Vector3.Distance(pathPoints[0].position, pathPoints[1].position);

        if (t > 1f) t = 0f;

        Vector3 point = GetBezierPoint(t, pathPoints[0].position, pathPoints[1].position, pathPoints[2].position);
        transform.position = point;

        playerCamera.transform.position = new Vector3(transform.position.x, transform.position.y, playerCamera.transform.position.z);
        playerCamera.transform.LookAt(transform);
    }
    Vector3 GetBezierPoint(float t, Vector3 p0, Vector3 p1, Vector3 p2)
    {
        float u = 1 - t;
        float tt = t * t;
        float uu = u * u;
        Vector3 p = uu * p0;
        p += 2 * u * t * p1;
        p += tt * p2;
        return p;
    }
}
