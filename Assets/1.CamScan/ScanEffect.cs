using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScanEffect : MonoBehaviour
{

    public Material ScanMat;

    public float ScanSpeed = 20;

    private float scanTimer = 0;

    private Camera scanCam;

    // Start is called before the first frame update
    void Awake()
    {
        scanCam = GetComponent<Camera>();
        scanCam.depthTextureMode = DepthTextureMode.Depth;

    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.C))
        {
            scanTimer = 0;
        }
        scanTimer += Time.deltaTime * ScanSpeed/scanCam.farClipPlane;
        ScanMat.SetFloat("_ScanDepth", scanTimer);

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        ScanMat.SetFloat("_CamFar", GetComponent<Camera>().farClipPlane);
        Graphics.Blit(source, destination, ScanMat);
    }




}
