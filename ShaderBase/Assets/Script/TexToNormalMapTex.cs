using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//该方法Unity本身就有,直接将贴图选择成NromalMap格式即可,这里只是给出实现原理
public class TexToNormalMapTex : MonoBehaviour 
{
	//原图
	public Texture2D tex0;
	//发现贴图
	public Texture2D tex1;

	public int width;

	public int hight;

	void Start () 
	{
		if (width == 0 || hight == 0) 
		{
			Debug.LogError ("请先设置图片的分辨率");
			return;
		}
		//这里不从0开始是因为如果从0开始原图上上下左右的顶点不一定有上下左右的像素点,所以从1开始,最大值也减去1也是这样的原因
		for (int w = 1; w < width - 1; w++) 
		{
			for (int h = 1; h < hight - 1; h++) 
			{
				//该像素点左边的像素点的灰度值
				float Uleft_gray = CalcGrayValue (tex0.GetPixel (w-1, h));

				//该像素点右边的像素点的灰度值
				float Uright_gray = CalcGrayValue (tex0.GetPixel (w+1, h));

				//用右边的减去左边的得到中间的灰度差值x
				float UDelta_x = Uright_gray - Uleft_gray;

				//该像素点上边的像素点的灰度值
				float Utop_gray = CalcGrayValue (tex0.GetPixel (w, h+1));

				//该像素点下边的像素点的灰度值
				float Ubootom_gray = CalcGrayValue (tex0.GetPixel (w, h-1));

				//用上边的减去下边的得到中间的灰度差值y
				float UDelta_y = Utop_gray - Ubootom_gray;

				//用中间的灰度差值x构建一个x轴方向的向量
				//用灰度差值x做为该向量的深度值就能体现出法线贴图x轴方向上的高度数据
				Vector3 u_vector = new Vector3(1,0,UDelta_x);

				//用中间的灰度差值y构建一个x轴方向的向量
				//用灰度差值y做为该向量的深度值就能体现出法线贴图y轴方向上的高度数据
				Vector3 v_vector = new Vector3(0,1,UDelta_y);

				//将以上的两个向量进行叉乘就可以得到法线信息了
				Vector3 N = Vector3.Cross(u_vector,v_vector).normalized;

				//由于我们最终要用颜色来表达法线贴图,所以N的三个分量取值范围要在(0,1)之间
				N.x = N.x/2 + 0.5f;
				N.y = N.y/2 + 0.5f;
				N.z = N.z/2 + 0.5f;

				//最后将得到的法线数据以颜色的形式存放到另外一张贴图中
				tex1.SetPixel (w, h, new Color (N.x, N.y, N.z));
			}
		}

		tex1.Apply (false);
	}


	//根据颜色值算出该像素的灰度值
	float CalcGrayValue(Color rgb)
	{
		//根据灰度计算公式Gray = (R*299 + G*587 + B*114 + 500) / 1000
		float gray = (rgb.r*299 + rgb.g*587 + rgb.b*114 + 500)/1000;
		return gray;
	}
}
