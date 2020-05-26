using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Continuously animates the shader variables of the specified Material to make it sweep the room.
/// </summary>
public class PulseAnimator : MonoBehaviour
{
    [Tooltip("The Material with Transition to animate")]
    public Material SurfaceMaterial;

    [Tooltip("Animation speed in meters per second")]
    public float Speed = 1.0f;

    [Tooltip("The maximum distance from the gaze hitpoint in meters.")]
    public float Range = 5.0f;

    void Update()
    {
        if (SurfaceMaterial)
        {
            float offset = Mathf.PingPong(Speed * Time.time, Range);
            SurfaceMaterial.SetFloat("_TransitionOffset", offset - 1);
        }
    }
}
