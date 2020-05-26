using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Continuously animates the shader variables of the specified Material to make it sweep the room.
/// </summary>
public class HighlightAnimator : MonoBehaviour 
{
    [Tooltip("The Material with Highlight to animate")]
    public Material SurfaceMaterial;

    public List<Vector3> TargetPositions = new List<Vector3>();

    public float smoothTime = 0.3F;
    private Vector3 velocity = Vector3.zero;
    private int currentTarget = 0;

    void Update()
    {
        if (SurfaceMaterial && TargetPositions.Count > 0)
        {
            var pos = SurfaceMaterial.GetVector("_LookAtPoint");
            if (Vector3.Distance(TargetPositions[currentTarget], pos) < 0.1)
            {
                currentTarget++;
                if (currentTarget >= TargetPositions.Count)
                {
                    currentTarget = 0;
                }
            }
            
            pos = Vector3.SmoothDamp(pos, TargetPositions[currentTarget], ref velocity, smoothTime);
            SurfaceMaterial.SetVector("_LookAtPoint", pos);
        }
    }
}
