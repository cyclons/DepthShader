using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Little class to rotate the gears
/// </summary>
public class GearAnimator : MonoBehaviour {
    public float GlobalSpeed = 1;
    public List<Transform> Gears = new List<Transform>();
    public List<float> Speed = new List<float>();

	void Update () {
		for (int i=0; i < Gears.Count; i++)
        {
            Gears[i].Rotate(0, 0, GlobalSpeed * Speed[i] * Time.deltaTime);
        }
	}
}
