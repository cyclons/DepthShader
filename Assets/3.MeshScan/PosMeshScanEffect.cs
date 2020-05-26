using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PosMeshScanEffect : MonoBehaviour
{
    public Material ScanMat;

    public float ScanSpeed = 20;

    public float scanTimer = 0;

    private Camera scanCam;

    private Vector3 ScanPoint = Vector3.zero;

    void Awake()
    {
    }

    private void Update()
    {

        scanCam = GetComponent<Camera>();
        scanCam.depthTextureMode |= DepthTextureMode.Depth;
        scanCam.depthTextureMode |= DepthTextureMode.DepthNormals;


        float aspect = scanCam.aspect;
        float farPlaneDistance = scanCam.farClipPlane;
        Vector3 midup = Mathf.Tan(scanCam.fieldOfView / 2 * Mathf.Deg2Rad) * farPlaneDistance * scanCam.transform.up;
        Vector3 midright = Mathf.Tan(scanCam.fieldOfView / 2 * Mathf.Deg2Rad) * farPlaneDistance * scanCam.transform.right * aspect;
        Vector3 farPlaneMid = scanCam.transform.forward * farPlaneDistance;

        Vector3 bottomLeft = farPlaneMid - midup - midright;
        Vector3 bottomRight = farPlaneMid - midup + midright;
        Vector3 upLeft = farPlaneMid + midup - midright;
        Vector3 upRight = farPlaneMid + midup + midright;

        Matrix4x4 frustumCorner = new Matrix4x4();
        frustumCorner.SetRow(0, bottomLeft);
        frustumCorner.SetRow(1, bottomRight);
        frustumCorner.SetRow(2, upRight);
        frustumCorner.SetRow(3, upLeft);

        ScanMat.SetMatrix("_FrustumCorner", frustumCorner);


        RaycastHit hit;
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        if (Input.GetMouseButtonDown(0)&&Physics.Raycast(ray,out hit))
        {
            scanTimer = 0;
            ScanPoint = hit.point;
        }
        scanTimer += Time.deltaTime;
        ScanMat.SetVector("_ScanCenter", ScanPoint);
        ScanMat.SetFloat("_ScanRange", scanTimer*ScanSpeed);

        ScanMat.SetMatrix("_CamToWorld", scanCam.cameraToWorldMatrix);

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        ScanMat.SetFloat("_CamFar", GetComponent<Camera>().farClipPlane);
        Graphics.Blit(source, destination, ScanMat);
    }

}
