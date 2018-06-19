using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase
{
    //分辨率  
    public int downSample = 1;
    //采样率,降低分辨率使用
    public int samplerScale = 1;
    //高亮部分提取阈值 ,在第一个pass中只有大于这个灰色的颜色值才会被输出
    public Color colorThreshold = Color.gray;
    //Bloom泛光颜色  
    public Color bloomColor = Color.white;
    //Bloom权值  
    [Range(0.0f, 1.0f)]
    public float bloomFactor = 0.5f;

    /// <summary>
    /// 屏幕后期处理
    /// </summary>
    /// <param name="source"></param>
    /// <param name="destination"></param>
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material)
        {
            //申请两块RT，并且分辨率按照downSameple降低  
            RenderTexture temp1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
            RenderTexture temp2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);

            //直接将场景图拷贝到低分辨率的RT上达到降分辨率的效果 ,第一次Blit将屏幕渲染的RT重新渲染到一张分辨率较低的temp1然后再交给Unity进行渲染
            Graphics.Blit(source, temp1);

            _Material.SetVector("_colorThreshold", colorThreshold);
            //提亮之后第二次进行Blit将提亮后的RT渲染到另一张RT:temp2中
            Graphics.Blit(temp1, temp2, _Material, 0);

            _Material.SetVector("_offsets", new Vector4(0, samplerScale, 0, 0));
            //第三次Blit进行纵向的高斯模糊后再将屏幕渲染的RT temp2传递到temp1中
            Graphics.Blit(temp2, temp1, _Material, 1);
            _Material.SetVector("_offsets", new Vector4(samplerScale, 0, 0, 0));
            //第四次Blit将横向的高斯模糊后再将屏幕渲染的RT temp1传递给temp2
            Graphics.Blit(temp1, temp2, _Material, 1);

            //最终将提亮并且再横向纵向上都进行了高斯模糊的RT 传递到Shader中
            _Material.SetTexture("_BlurTex", temp2);
            _Material.SetVector("_bloomColor", bloomColor);
            _Material.SetFloat("_bloomFact", bloomFactor);

            //最终混合输出
            Graphics.Blit(source, destination, _Material,2);

            //释放申请的RT  
            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
        }
    }
}
