using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 局部热扭曲脚本,需要将该脚本挂在摄像机上,主要使用一张RenderTexure来做为Mask实现局部热扭曲的效果,同样也不需要在Shader中使用GrabPass尤其在手机平台不适合用GrabPass,场景中还需要创建一个面片(层级为Distort)来做为遮罩
/// </summary>
public class SmallDistorEffect : PostEffectBase
{
    //扭曲的时间系数  
    [Range(0.0f, 1.0f)]
    public float DistortTimeFactor = 0.15f;
    //扭曲的强度  
    [Range(0.0f, 0.2f)]
    public float DistortStrength = 0.01f;
    //噪声图  
    public Texture NoiseTexture = null;
    //渲染Mask图所用的shader  
    public Shader maskObjShader = null;
    //降采样系数  
    public int downSample = 4;

    private Camera mainCam = null;
    private Camera additionalCam = null;
    private RenderTexture renderTexture = null;


    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material)
        {
            _Material.SetTexture("_NoiseTex", NoiseTexture);
            _Material.SetFloat("_DistortTimeFactor", DistortTimeFactor);
            _Material.SetFloat("_DistortStrength", DistortStrength);
            _Material.SetTexture("_MaskTex", renderTexture);
            Graphics.Blit(source, destination, _Material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    private void Awake()
    {
        InitAdditionalCam();
    }

    /// <summary>
    /// 创建一个相机来渲染一个热扭曲面片
    /// </summary>
    private void InitAdditionalCam()
    {
        mainCam = GetComponent<Camera>();
        if (mainCam == null)
            return;

        Transform addCamTransform = transform.FindChild("additionalDistortCam");
        if (addCamTransform != null)
            DestroyImmediate(addCamTransform.gameObject);

        GameObject additionalCamObj = new GameObject("additionalDistortCam");
        additionalCam = additionalCamObj.AddComponent<Camera>();

        SetAdditionalCam();
    }

    /// <summary>
    /// 创建一个相机来渲染一个热扭曲面片
    /// </summary>
    private void SetAdditionalCam()
    {
        if (additionalCam)
        {
            additionalCam.transform.parent = mainCam.transform;
            additionalCam.transform.localPosition = Vector3.zero;
            additionalCam.transform.localRotation = Quaternion.identity;
            additionalCam.transform.localScale = Vector3.one;
            additionalCam.farClipPlane = mainCam.farClipPlane;
            additionalCam.nearClipPlane = mainCam.nearClipPlane;
            additionalCam.fieldOfView = mainCam.fieldOfView;
            additionalCam.backgroundColor = Color.clear;
            additionalCam.clearFlags = CameraClearFlags.Color;
            additionalCam.cullingMask = 1 << LayerMask.NameToLayer("Distort");//注意将场景中的热扭曲面片设置为这个层
            additionalCam.depth = -999;
            //分辨率可以低一些,不影响效果,这里实际上就是用一张RenderTexture作为一张Mask使用,因为该相机只渲染Distort的物体,也就是说只渲染场景中被设置为Distort层的热扭曲面片,而这个面片就是Mask
            if (renderTexture == null)
                renderTexture = RenderTexture.GetTemporary(Screen.width >> downSample, Screen.height >> downSample, 0);
        }
    }

    void OnEnable()
    {
        SetAdditionalCam();
        additionalCam.enabled = true;
    }

    void OnDisable()
    {
        additionalCam.enabled = false;
    }

    void OnDestroy()
    {
        if (renderTexture)
        {
            RenderTexture.ReleaseTemporary(renderTexture);
        }
        DestroyImmediate(additionalCam.gameObject);
    }

    //在相机渲染当前场景之前调用,此处用来渲染MASK
    void OnPreRender()
    {
        //maskObjShader进行渲染  
        if (additionalCam.enabled)
        {
            additionalCam.targetTexture = renderTexture;
            //指定相机使用maskObjShader来渲染物体,这个Shader实际上就是热扭曲的mask这个shader,它仅仅输出一个白色(1,1,1,1)
            additionalCam.RenderWithShader(maskObjShader, "");
        }
    }
}
