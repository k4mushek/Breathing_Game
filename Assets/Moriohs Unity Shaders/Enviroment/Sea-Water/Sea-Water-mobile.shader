// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Moriohs Shaders/Enviroment Shaders/Sea-Water-mobile"
{
	Properties
	{
		[ShaderOptimizerLockButton]_ShaderOptimizerEnabled("PLEASE IMPORT KAJSHADEROPTIMIZER SCRIPT WITHIN ITS EDITOR FOLDER", Float) = 0
		[Header(MAIN OPTIONS)]_WaterColor("WaterColor", Color) = (0,0.3490196,0.3254902,0)
		_GeneralFoamAmount("General Foam Amount", Range( 0 , 1)) = 0.645
		_GeneralFoamStrength("General Foam Strength", Float) = 1.65
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.94
		_UVTiling("UV Tiling", Float) = 0.01
		[Space(25)][Header(NORMAL MAPS)]_Normal("Normal", 2D) = "bump" {}
		_ScrollSpeed("Scroll Speed", Range( -2 , 2)) = 0.075
		_NormalScale("Normal Scale", Range( -2 , 2)) = 0.2
		_VectorXY("Vector X,Y", Vector) = (0,-1,0,0)
		_SecondaryNormal("Secondary Normal", 2D) = "bump" {}
		_SecondaryScrollSpeed("Secondary Scroll Speed", Range( -2 , 2)) = 0.17
		_NormalScaleSecondary("Normal Scale Secondary", Range( -2 , 2)) = 0.2
		_SecondaryVectorXY("Secondary Vector X,Y", Vector) = (0,-1,0,0)
		[HideInInspector][ToggleUI]_NormalScaleAnimated("Normal Scale Animated", Int) = 1
		[HideInInspector][ToggleUI]_NormalScaleSecondaryAnimated("Normal Scale Secondary Animated", Int) = 1
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" }
		Cull Back
		ZWrite On
		CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#pragma only_renderers d3d11 glcore gles gles3 nomrt 
		#pragma surface surf Standard keepalpha noshadow exclude_path:deferred nolightmap  nodynlightmap nodirlightmap nometa 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _ShaderOptimizerEnabled;
		uniform int _NormalScaleSecondaryAnimated;
		uniform int _NormalScaleAnimated;
		uniform sampler2D _Normal;
		uniform float _ScrollSpeed;
		uniform float2 _VectorXY;
		uniform float4 _Normal_ST;
		uniform float _UVTiling;
		uniform float _NormalScale;
		uniform sampler2D _SecondaryNormal;
		uniform float _SecondaryScrollSpeed;
		uniform float2 _SecondaryVectorXY;
		uniform float4 _SecondaryNormal_ST;
		uniform float _NormalScaleSecondary;
		uniform float4 _WaterColor;
		uniform float _GeneralFoamStrength;
		uniform float _GeneralFoamAmount;
		uniform float _Smoothness;


		float2 hash2D2D( float2 s )
		{
			return frac(sin(fmod(float2(dot(s, float2(127.1,311.7)), dot(s, float2(269.5,183.3))), 3.14159))*43758.5453);
		}


		void SourceDeclaration(  )
		{
			//This Shader was made possible by Moriohs Toon Shader (https://gitlab.com/xMorioh/moriohs-toon-shader)
		}


		float3 tex2DStochasticNormals( sampler2D tex, float2 UV, float _NormalScale )
		{
			    //triangle vertices and blend weights
			    //BW_vx[0...2].xyz = triangle verts
			    //BW_vx[3].xy = blend weights (z is unused)
			    float4x3 BW_vx;
			    //uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)
			    float2 skewUV = mul(float2x2 (1.0 , 0.0 , -0.57735027 , 1.15470054), UV * 3.464);
			    //vertex IDs and barycentric coords
			    float2 vxID = float2 (floor(skewUV));
			    float3 barry = float3 (frac(skewUV), 0);
			    barry.z = 1.0-barry.x-barry.y;
			    BW_vx = ((barry.z>0) ? 
			        float4x3(float3(vxID, 0), float3(vxID + float2(0, 1), 0), float3(vxID + float2(1, 0), 0), barry.zyx) :
			        float4x3(float3(vxID + float2 (1, 1), 0), float3(vxID + float2 (1, 0), 0), float3(vxID + float2 (0, 1), 0), float3(-barry.z, 1.0-barry.y, 1.0-barry.x)));
			    //calculate derivatives to avoid triangular grid artifacts
			    float2 dx = ddx(UV);
			    float2 dy = ddy(UV);
			    //blend samples with calculated weights
			    return mul (UnpackScaleNormal(tex2D(tex, UV + hash2D2D(BW_vx[0].xy), dx, dy), _NormalScale), BW_vx[3].x) + 
			            mul (UnpackScaleNormal(tex2D(tex, UV + hash2D2D(BW_vx[1].xy), dx, dy), _NormalScale), BW_vx[3].y) + 
			            mul (UnpackScaleNormal(tex2D(tex, UV + hash2D2D(BW_vx[2].xy), dx, dy), _NormalScale), BW_vx[3].z);
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			sampler2D tex96_g33 = _Normal;
			float mulTime7_g33 = _Time.y * _ScrollSpeed;
			float temp_output_68_0_g33 = _UVTiling;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult105_g33 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 temp_output_104_0_g33 = ( ( _Normal_ST.xy * temp_output_68_0_g33 * appendResult105_g33 ) + _Normal_ST.zw );
			float2 panner17_g33 = ( mulTime7_g33 * _VectorXY + temp_output_104_0_g33);
			float2 UV96_g33 = ( panner17_g33 + 0.25 );
			float _NormalScale96_g33 = _NormalScale;
			float3 localtex2DStochasticNormals96_g33 = tex2DStochasticNormals( tex96_g33 , UV96_g33 , _NormalScale96_g33 );
			sampler2D tex79_g33 = _Normal;
			float mulTime4_g33 = _Time.y * _ScrollSpeed;
			float2 panner12_g33 = ( ( mulTime4_g33 * 2.179 ) * _VectorXY + ( 1.0 - temp_output_104_0_g33 ));
			float2 UV79_g33 = ( 1.0 - panner12_g33 );
			float _NormalScale79_g33 = _NormalScale;
			float3 localtex2DStochasticNormals79_g33 = tex2DStochasticNormals( tex79_g33 , UV79_g33 , _NormalScale79_g33 );
			sampler2D tex76_g33 = _SecondaryNormal;
			float mulTime16_g33 = _Time.y * _SecondaryScrollSpeed;
			float2 panner21_g33 = ( mulTime16_g33 * _SecondaryVectorXY + ( ( _SecondaryNormal_ST.xy * temp_output_68_0_g33 * appendResult105_g33 ) + _SecondaryNormal_ST.zw ));
			float2 UV76_g33 = panner21_g33;
			float _NormalScale76_g33 = _NormalScaleSecondary;
			float3 localtex2DStochasticNormals76_g33 = tex2DStochasticNormals( tex76_g33 , UV76_g33 , _NormalScale76_g33 );
			float3 normalizeResult66_g33 = normalize( BlendNormals( BlendNormals( localtex2DStochasticNormals96_g33 , localtex2DStochasticNormals79_g33 ) , localtex2DStochasticNormals76_g33 ) );
			float3 Normals80 = normalizeResult66_g33;
			o.Normal = Normals80;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV416 = dot( (WorldNormalVector( i , Normals80 )), ase_worldViewDir );
			float fresnelNode416 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV416, 5.0 ) );
			float3 temp_cast_0 = (( ( 1.0 - _GeneralFoamAmount ) * _GeneralFoamStrength )).xxx;
			float3 temp_cast_1 = (1.0).xxx;
			float dotResult409 = dot( ( ( Normals80 * _GeneralFoamStrength ) - temp_cast_0 ) , temp_cast_1 );
			float temp_output_410_0 = saturate( dotResult409 );
			o.Albedo = ( ( fresnelNode416 * _WaterColor ) + temp_output_410_0 ).rgb;
			o.Smoothness = ( ( 1.0 - temp_output_410_0 ) * _Smoothness );
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
21;29;2106;954;-566.1816;183.26;1.021579;True;False
Node;AmplifyShaderEditor.CommentaryNode;82;1120,432;Inherit;False;681.7088;240.9818;;3;80;415;383;NormalMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;383;1136,496;Inherit;False;Property;_UVTiling;UV Tiling;5;0;Create;True;0;0;0;False;0;False;0.01;1500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;415;1296,496;Inherit;False;Normal scroll;6;;33;8e7734c034edf454cad15a4da30f1093;0;1;68;FLOAT;0;False;5;FLOAT3;0;FLOAT2;83;FLOAT;87;FLOAT2;98;FLOAT;97
Node;AmplifyShaderEditor.CommentaryNode;400;736,32;Inherit;False;1049.65;335.0648;;10;410;409;408;407;406;405;403;402;404;401;General Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;1600,496;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;401;784,240;Inherit;False;Property;_GeneralFoamAmount;General Foam Amount;2;0;Create;True;0;0;0;False;0;False;0.645;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;402;784,160;Inherit;False;Property;_GeneralFoamStrength;General Foam Strength;3;0;Create;True;0;0;0;False;0;False;1.65;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;403;1056,240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;404;896,80;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;405;1072,112;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;1200,240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;424;1168,-336;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;408;1344,208;Inherit;False;Constant;_Float2;Float 2;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;407;1344,112;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;423;1344,-336;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;409;1504,112;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;410;1632,112;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;416;1536,-336;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;43;1536,-160;Inherit;False;Property;_WaterColor;WaterColor;1;1;[Header];Create;True;1;MAIN OPTIONS;0;0;False;0;False;0,0.3490196,0.3254902,0;0,0.4196044,0.4339588,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;1840,464;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0.94;0.94;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;418;1808,-176;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;413;1952,384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;2080,304;Inherit;False;80;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;374;2112,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;421;2240,96;Inherit;False;Property;_NormalScaleSecondaryAnimated;Normal Scale Secondary Animated;17;1;[HideInInspector];Create;True;0;0;0;True;1;ToggleUI;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;420;2256,0;Inherit;False;Property;_NormalScaleAnimated;Normal Scale Animated;16;1;[HideInInspector];Create;True;0;0;0;True;1;ToggleUI;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;288;2096,192;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;422;2256,176;Inherit;False;Property;_ShaderOptimizerEnabled;PLEASE IMPORT KAJSHADEROPTIMIZER SCRIPT WITHIN ITS EDITOR FOLDER;0;0;Create;False;0;0;0;True;1;ShaderOptimizerLockButton;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2261.179,263.2598;Float;False;True;-1;7;ASEMaterialInspector;0;0;Standard;Moriohs Shaders/Enviroment Shaders/Sea-Water-mobile;False;False;False;False;False;False;True;True;True;False;True;False;False;False;True;True;False;False;True;True;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;ForwardOnly;5;d3d11;glcore;gles;gles3;nomrt;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;1;1;10;1000;False;0.5;False;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;2;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;Diffuse;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;415;68;383;0
WireConnection;80;0;415;0
WireConnection;403;0;401;0
WireConnection;405;0;404;0
WireConnection;405;1;402;0
WireConnection;406;0;403;0
WireConnection;406;1;402;0
WireConnection;407;0;405;0
WireConnection;407;1;406;0
WireConnection;423;0;424;0
WireConnection;409;0;407;0
WireConnection;409;1;408;0
WireConnection;410;0;409;0
WireConnection;416;0;423;0
WireConnection;418;0;416;0
WireConnection;418;1;43;0
WireConnection;413;0;410;0
WireConnection;374;0;413;0
WireConnection;374;1;39;0
WireConnection;288;0;418;0
WireConnection;288;1;410;0
WireConnection;0;0;288;0
WireConnection;0;1;81;0
WireConnection;0;4;374;0
ASEEND*/
//CHKSM=2FD9D4B72CDB7EB9927AF88D271DC0BE9BB3BC79