struct a2v
{
	float4 vertex : POSITION;
	float3 normal:NORMAL;
};

struct v2f
{
	float4 vertex : SV_POSITION;
	float3 wPos:TEXCOORD1;
	float3 normal:TEXCOORD2;
};
uniform fixed4 _ProjectionColor;
uniform float _ProjectionLength;
uniform float _ProjectionFadeout;
v2f vert(a2v v)
{
	v2f o;
	//世界空间顶点坐标
	o.wPos = mul(unity_ObjectToWorld, v.vertex);
	//世界空间法线
	o.normal = UnityObjectToWorldNormal(v.normal);

	//世界空间光向量单位化
	float3 lightDir = normalize(UnityWorldSpaceLightDir(o.wPos));
	//法线挤压
	v.vertex.xyz += v.normal*0.01;

	//顶点变换到世界空间
	v.vertex = mul(UNITY_MATRIX_M, v.vertex);

	//法向量和光向量的点积
	float NdotL = min(0, dot(o.normal, lightDir));

	//大量的法线挤压,依据的是漫反射效果和自定义的_ProjectionLength值的积
	v.vertex.xyz += lightDir *NdotL* _ProjectionLength;

	//将顶点转换到齐次裁剪空间(也就是我们最终看到的空间)
	o.vertex = v.vertex = mul(UNITY_MATRIX_VP, v.vertex);
	return o;
}
fixed4 frag(v2f i) : SV_Target
{
	fixed4 col = _ProjectionColor;
	float NdotL = dot(i.normal, normalize(UnityWorldSpaceLightDir(i.wPos)));
	//根据自定义变量_ProjectionColor的alpha通道和NdotL来决定投影的透明变化
	col.a = min(_ProjectionColor.a,(pow(1.1 - abs(NdotL), 8)));
	//用自定义变量_ProjectionFadeout来控制投影的透明度
	col.a *= pow(min(distance(_WorldSpaceCameraPos.xyz, i.wPos), _ProjectionFadeout) / _ProjectionFadeout, 3);
	return col;
}