using Godot;
using System;
using System.Collections.Generic;

public partial class Leg : Marker2D
{
	const float MIN_DIST = 10;
  Node2D Knee;
  Node2D Foot;

	public float lenUpper = 0;
	public float lenLower = 0;
	
	public bool flip = true;
  public bool walking = false;


	Vector2 goalPos = new Vector2();
  Vector2 intPos = new Vector2();
  Vector2 startPos = new Vector2();

	float stepTime = 0.0f;
	float funcTime = 0f;

	[Export]
  float stepHeight = 30f;
  float stepRate = 0.5f;
	[Export]
  float leglength = 50f;
	[Export]
  float legArch = 20f;
	[Export]
  float legSpeed = 12f;

  public override void _Ready()
  {
		Knee = GetNode<Node2D>("Knee");
    Foot = Knee.GetNode<Node2D>("Foot");
		lenUpper = Knee.Position.X;
		lenLower = Foot.Position.X;
  }

	float LawOfCos(float a, float b, float c) 
	{
    if (2 * a * b == 0) {
      return 0;
    }

    return (float)Math.Acos((a * a + b * b - c * c) / (2 * a * b));
  }

	Dictionary<string, float> SSSCalc(float side_a, float side_b, float side_c)
  {
    if (side_c >= side_a + side_b)
    {
      return new Dictionary<string, float>
      {
        {"A", 0},
        {"B", 0},
        {"C", 0}
      };
    }

    float angle_a = LawOfCos(side_b, side_c, side_a);
    float angle_b = LawOfCos(side_c, side_a, side_b) + Mathf.Pi;
    float angle_c = Mathf.Pi - angle_a - angle_b;

    if (flip)
    {
      angle_a = -angle_a;
      angle_b = -angle_b;
      angle_c = -angle_c;
    }
		

    return new Dictionary<string, float>
    {
      {"A", angle_a},
      {"B", angle_b},
      {"C", angle_c}
    };
  }

	void UpdateIK(Vector2 targetPos)
    {
        Vector2 offset = targetPos - GlobalPosition;
        float disToTarget = offset.Length();
        if (disToTarget < MIN_DIST)
        {
            offset = (offset / disToTarget) * MIN_DIST;
            disToTarget = MIN_DIST;
        }

        float baseR = offset.Angle();
				
        Dictionary<string, float> baseAngles = SSSCalc(lenUpper, lenLower, disToTarget);
        GlobalRotation = baseAngles["A"] + baseR;
        Knee.Rotation = baseAngles["C"];
    }
  void UpdateFoot() 
  {
    float rotation;
    Vector2 mousePosition = GetGlobalMousePosition() - GlobalPosition;
    if(flip) {
        rotation = -(float)Math.PI/2;
        if(!walking) {
          if(mousePosition.Y < 0) rotation += -(float)Math.PI/4 -(float)Math.Sin(funcTime*2)*(float)Math.PI/11;
          else rotation += (float)Math.PI/10 -(float)Math.Sin(funcTime*2)*(float)Math.PI/11;
        }
    } else {
        rotation = (float)Math.PI -(float)Math.PI/2;
        if(!walking) {
          if(mousePosition.Y < 0) rotation -= -(float)Math.PI/4 -(float)Math.Sin(funcTime*2)*(float)Math.PI/11;
          else rotation -= (float)Math.PI/10 -(float)Math.Sin(funcTime*2)*(float)Math.PI/11;
        }
    }
    Foot.Rotation = rotation;

  }
	
	void Step(double delta, int legN, bool _flip, bool _walking) { 
      float PosX, PosY;
      walking = _walking;
      flip = _flip;
      int dir;
      if(flip) dir = 1;
      else dir = -1;
      Vector2 footPos = Foot.GlobalPosition; 
      //funcTime += (float)delta;
      startPos = footPos;
      float legDist;
      Vector2 position = Position;
      if(walking) {
        legDist = 10;
        position.Y = 20;
        if(legN ==  1) {
          PosX = (float)Math.Cos(dir*funcTime*legSpeed)*legArch;
          PosY = (float)Math.Sin(dir*funcTime*legSpeed)*stepHeight;
        } else {
          PosX = (float)Math.Cos(dir*funcTime*legSpeed+Math.PI)*legArch;
          PosY = (float)Math.Sin(dir*funcTime*legSpeed+Math.PI)*stepHeight;
        }
      } else {
        GlobalRotation = 0;
        legDist = 20;
        position.Y = 10;
        PosX = 0; 
        PosY = -(float)Math.Sin(funcTime*2)*5f;
      }
      if(legN == 1) position.X = legDist;
      else if(legN == 2) position.X = -legDist;
      Position = position;
      if(walking) {
        if(legN == 1) goalPos = new Vector2(PosX + legDist, PosY+leglength) + GlobalPosition;
        else if(legN == 2) goalPos = new Vector2(PosX - legDist, PosY+leglength) + GlobalPosition;
      } else {
        goalPos = new Vector2(PosX, PosY+65) + GlobalPosition;
      }
	}


  public override void _Process(double delta)
	{
		stepTime += (float)delta;
		float t = stepTime / stepRate;
		Vector2 targetPos = new Vector2();
		if (t < 0.5f)
		{
			targetPos = startPos.Lerp(goalPos, t / 0.5f);
		}
		else {
			targetPos = goalPos;
		}
		UpdateIK(targetPos);
    UpdateFoot();
	}


}
