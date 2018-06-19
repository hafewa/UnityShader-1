using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 全屏热扭曲脚本,需要将该脚本挂在摄像机上,使用屏幕后处理的好处是不需要在Shader使用GrabPass了，GrabPass很耗性能
/// </summary>
public class DistortEffect : PostEffectBase
{
    /// <summary>
    /// 扭曲的时间系数(speed)
    /// </summary>
    [Range(0.0f, 1.0f)]
    public float DistortTimeFactor = 0.15f;

    /// <summary>
    /// 扭曲的强度
    /// </summary>
    [Range(0.0f, 0.2f)]
    public float DistortStrength = 0.01f;

    /// <summary>
    /// 控制扭曲的噪声图
    /// </summary>
    public Texture NoiseTex;

    /// <summary>
    /// 屏幕后期处理
    /// </summary>
    /// <param name="source"></param>
    /// <param name="destination"></param>
    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(_Material)
        {
            _Material.SetTexture("_NoiseTex", NoiseTex);
            _Material.SetFloat("_DistortTimeFactor", DistortTimeFactor);
            _Material.SetFloat("_DistortStrength", DistortStrength);
            Graphics.Blit(source, destination, _Material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
