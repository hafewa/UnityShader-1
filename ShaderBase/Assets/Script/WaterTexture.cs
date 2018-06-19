using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Threading;

public class WaterTexture : MonoBehaviour {

	private float[,] waveA;
	private float[,] waveB;

	public int width = 128;
	public int hight = 128;

	private Texture2D tex;

	private Color[] cols;

	private Material mat;

	private bool isRun = true;

	private int SleepTime;

	void Start () 
	{
		waveA = new float[width, hight];
		waveB = new float[width, hight];

		tex = new Texture2D (width, hight);

		mat = GetComponent<Renderer> ().material;

		mat.SetTexture ("_WaveTex", tex);

		//因为非主线程不能使用tex.SetPixel和tex.Apply ()方法,所以这里申请一个主线程和副线程之间的内存共享区域来传递数据
		cols = new Color[width * hight];

		//因为效率问题开启一个线程来处理波形算法,这样会大大优化性能
		Thread th = new Thread (ComputeWave);

		th.Start ();
	}
	

	void Update () 
	{
		SleepTime = (int)Time.deltaTime * 1000;
		//在主线程中使用tex.SetPixel和tex.Apply
		if (cols.Length > 0)
		{
			tex.SetPixels (cols);
			//实施更新像素
			tex.Apply ();
		}
	
		if (Input.GetMouseButton (0)) 
		{
			RaycastHit hit;
			Ray ray = Camera.main.ScreenPointToRay (Input.mousePosition);

			if (Physics.Raycast (ray, out hit)) 
			{
				//世界坐标
				Vector3 pos = hit.point;

				//转换到本地坐标(如果不转换到本地坐标就不能根据坐标算出点了模型上的哪个位置,从而产生波纹)
				pos = hit.transform.worldToLocalMatrix.MultiplyPoint (pos);

				//转换模型位置(因为面片模型点的取值范围是(-0.5,0.5))
				int x = (int)((pos.x + 0.5) * width);
				int y = (int)((pos.y + 0.5) * hight);

				PutDrop (x, y);
			}
		} 
	}


	//投放一颗小石头,相当于给某些点初始化一些能量
	private void PutDrop(int x, int y)
	{
		//波的半径
		int radius = 8;
		float dist;

		for(int i = -radius; i<=radius; i++)
		{
			for(int j = -radius; j<=radius; j++)
			{
				//(x,y)相当于圆心
				if(((x+i>=0) && (x+i<width-1)) && ((y+j>=0) && (y+j<hight-1)))
				{
					//离圆心的距离
					dist = Mathf.Sqrt(i*i +j*j);
					//当离圆心的距离小于半径的时候
					if(dist<radius)
						waveA[x+i,y+j] = Mathf.Cos(dist*Mathf.PI  / radius);//给该点一个余弦值的能量,其参数正是依靠离圆心的距离决定,这样离圆心越近能量越大,反之越小,而且余弦还有正负,这样形成的波就有高低起伏,更加真实
				}
			}
		}
	}

	void ComputeWave()
	{
		while (isRun) 
		{
			//因为下面会取到 waveB [w-1, h],所以不能从0开始
			for (int w = 1; w < width - 1; w++) 
			{
				for (int h = 1; h < hight - 1; h++) 
				{
					//这个是波形算法,具体为什么这样实现不清,codeProject(类似国内的CSDN)网站上有个WaterEffect的水波特效工程(纯用C#写的)就是使用这个算法
					//理解是将有能量的点存储在两个缓冲区中,然后计算每一个有能量点的周围八个点的和再除以4,然后减去另一个缓冲区中该点的能量(也就是上一帧该点的能量),最后将两个缓冲区能量进行交换
					waveB [w, h] = (waveA [w - 1, h] +
						waveA [w, h + 1] +
						waveA [w + 1, h] +
						waveA [w, h - 1] +
						waveA [w - 1, h + 1] +
						waveA [w + 1, h + 1] +
						waveA [w - 1, h - 1] +
						waveA [w + 1, h - 1]) /4 -waveB [w, h];

					if (waveB [w, h] > 1)
						waveB [w, h] = 1;
					if (waveB [w, h] < -1)
						waveB [w, h] = -1;

					//因为waveB中每个点的最大值是1,最小值是-1,所以减过后的取值范围是(-2,2).再除以2便将数据变换到(-1,1)之间
					float offset_u = (waveB [w-1, h] - waveB [w+1, h]) / 2;
					float offset_v = (waveB [w, h-1] - waveB [w, h+1]) / 2;

					//因为是颜色显示,所以转换到（0,1）
					offset_u = (float)(offset_u / 2 + 0.5);
					offset_v = (float)(offset_v / 2 + 0.5);

					//用红色和绿色通道颜色来显示此时的波纹
					//tex.SetPixel(w, h,new Color(offset_u,offset_v,0));

					//将波形纹理数据存在主线程和副线程的共享内存中
					cols [w  + width* h] = new Color (offset_u, offset_v, 0);

					//每次循环衰减一点,这样就会使得波的能量越来越小
					waveB [w, h] -= (float)(0.01 * waveB [w, h]);
				}
			}
			//将两个能量缓冲区交换,这也是算法的一部分
			float[,] temp = waveB;

			waveB = waveA;

			waveA = temp;

			Thread.Sleep (SleepTime);
		}
	}


	void OnDestroy()
	{
		isRun = false;
	}
}
