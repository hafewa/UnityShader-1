using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;


//这个模拟投石水波效果的主要逻辑都写在C#代码中,从而大大减少GPU的工作量,缺点是C#中需要开一个单独的线程来计算水波数据
//本shader只适用于类似Unity的内置3D面片资源Quad,不能用其他的3D资源,因为Quad的坐标是(x,y)的,而Plane是(x,z)的
public class WaveWater : MonoBehaviour
{
    //长宽越小水波越激烈和快速
    public  int width = 128;
    public int hight = 128;

    private Material mat;
    private Texture2D waveTex;

    private bool isRun = true;
    private Color[] cols;

    float[,] waveA;
    float[,] waveB;

    int sleepTime;

    void Start ()
    {
        mat = GetComponent<Renderer>().material;
        waveTex = new Texture2D(width, hight);
        cols = new Color[width * hight];
        waveA = new float[width, hight];
        waveB = new float[width, hight];

        mat.SetTexture("_WaveTex", waveTex);

        //开启一个线程来计算水波纹理的每个点的能量数据(用waveTex的rg通道来存储)
        //线程是为了性能考虑,计算水波数据需要大量的计算,在主线程计算会使得画面很卡
        Thread t = new Thread(CalcWaveData);
        t.Start();
    }

    //计算水波数据线程,将计算结果存在了cols中
    void CalcWaveData()
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
                    waveB[w, h] = (waveA[w - 1, h] +
                        waveA[w, h + 1] +
                        waveA[w + 1, h] +
                        waveA[w, h - 1] +
                        waveA[w - 1, h + 1] +
                        waveA[w + 1, h + 1] +
                        waveA[w - 1, h - 1] +
                        waveA[w + 1, h - 1]) / 4 - waveB[w, h];

                    if (waveB[w, h] > 1)
                        waveB[w, h] = 1;
                    if (waveB[w, h] < -1)
                        waveB[w, h] = -1;

                    //因为waveB中每个点的最大值是1,最小值是-1,所以减过后的取值范围是(-2,2).再除以2便将数据变换到(-1,1)之间
                    float offset_u = (waveB[w - 1, h] - waveB[w + 1, h]) / 2;
                    float offset_v = (waveB[w, h - 1] - waveB[w, h + 1]) / 2;

                    //因为是颜色显示,所以转换到（0,1）
                    offset_u = (float)(offset_u / 2 + 0.5);
                    offset_v = (float)(offset_v / 2 + 0.5);

                    //用红色和绿色通道颜色来显示此时的波纹
                    //tex.SetPixel(w, h,new Color(offset_u,offset_v,0));

                    //将波形纹理数据存在主线程和副线程的共享内存中
                    cols[w + width * h] = new Color(offset_u, offset_v, 0);

                    //每次循环衰减一点,这样就会使得波的能量越来越小
                    waveB[w, h] -= (float)(0.01 * waveB[w, h]);
                }
            }
            //将两个能量缓冲区交换,这也是算法的一部分
            float[,] temp = waveB;

            waveB = waveA;

            waveA = temp;

            Thread.Sleep(sleepTime);
        }
    }
	
    //模拟石头投入水波的操作(鼠标点击模型的某一点就类似有个小石头投入水面上)
	void Update ()
    {
        //设置线程睡眠时间
        sleepTime = (int)Time.deltaTime * 1000;

        if(cols.Length > 0)
        {
            //将线程中计算的水波数据传给纹理waveTex
            waveTex.SetPixels(cols);
            waveTex.Apply();
        }

        if(Input.GetMouseButton(0))
        {
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

            if(Physics.Raycast(ray,out hit))
            {
                //点击到了模型,hit.point是世界坐标
                Vector3 pos = hit.point;
                //转换为本地坐标,因为要根据模型的本地坐标来计算水波的能量大小
                pos = hit.transform.worldToLocalMatrix.MultiplyPoint(pos);
                //pos既是点击到的模型那一点的本地坐标,我们是用一个面片Plane做为测试,而面片Plane的本地坐标的范围是(-0.5,0.5)
                //waveA和waveB是做为计算水波数据所使用到的二维数组,而数组的下标不能为小数,所以现在将pos转换到(0,1)之间
                int x = (int)((pos.x + 0.5) * width);
                int y = (int)((pos.y + 0.5) * hight);

                //模拟小石头投入水中
                PutDrop(x, y);
            }
        }
	}


    //投放一颗小石头,相当于给某些点初始化一些能量
    private void PutDrop(int x, int y)
    {
        //波的半径
        int radius = 8;
        float dist;

        for (int i = -radius; i <= radius; i++)
        {
            for (int j = -radius; j <= radius; j++)
            {
                //(x,y)相当于圆心
                if (((x + i >= 0) && (x + i < width - 1)) && ((y + j >= 0) && (y + j < hight - 1)))
                {
                    //离圆心的距离
                    dist = Mathf.Sqrt(i * i + j * j);
                    //当离圆心的距离小于半径的时候
                    if (dist < radius)
                        waveA[x + i, y + j] = Mathf.Cos(dist * Mathf.PI / radius);//给该点一个余弦值的能量,其参数正是依靠离圆心的距离决定,这样离圆心越近能量越大,反之越小,而且余弦还有正负,这样形成的波就有高低起伏,更加真实
                }
            }
        }
    }

    void OnDestroy()
    {
        isRun = false;
    }
}
