using Godot;
using System;
public partial class LegMovement : CharacterBody2D
{
		Node leg1;
    Node leg2;
    Node2D Hat;
    Node2D Hand1;
    Node2D Hand2;
    Node2D Inventory;

    float stepRate = 100f;
		bool flip = false;
	  float timeSinceLastStep = 0;
    float funcTime = 0f;
    [Export]
    float legBounce = 0.2f;
    [Export]
    float offsetAngle = 1.7f;

    public const float Speed = 600.0f;
	  public const float Accel = 50.0f;
	

    public override void _Ready()
    {
        leg1 = GetNode("Leg1");
        leg2 = GetNode("Leg2");
        Hat = GetNode<Node2D>("Hat");
        Hand1 = GetNode<Node2D>("Hand1");
        Hand2 = GetNode<Node2D>("Hand2");
        Inventory = GetNode<Node2D>("PlayerInventory");
    }

    public override void _PhysicsProcess(double delta)
	  {
      Vector2 velocity = Velocity;
      Vector2 direction = Input.GetVector("left", "right", "up", "down");

      velocity.X = Mathf.MoveToward(velocity.X, Speed * direction.X, Accel);
      velocity.Y = Mathf.MoveToward(velocity.Y, Speed * direction.Y, Accel);


      Velocity = velocity;
      MoveAndSlide();
	  }


    public override void _Process(double delta)
    {
			Vector2 direction = Input.GetVector("left", "right", "up", "down");
      bool walking = true;
			if(direction.X < 0) flip = false;
			else if(direction.X > 0) flip = true;
      else {
        if(direction.Y == 0) {
          walking = false;
        }
      }
      timeSinceLastStep += (float)delta;
      funcTime += (float)delta;

      BodyMov(walking, direction);
      HandMov(walking);

      if (timeSinceLastStep >= 1/stepRate) {
          Step(delta, flip, walking);
          timeSinceLastStep = 0;
      }
      
    }

    void BodyMov(bool walking, Vector2 direction) {
      Vector2 position = GlobalPosition;
      GlobalRotation = -direction.X * (float)Math.PI/11;
      Vector2 wave = new Vector2(0, (float)Math.Sin(funcTime*2+offsetAngle)*legBounce);
      if(!walking) {
        GlobalRotation = 0;
        position += wave;
      } 
      GlobalPosition = position;
    }

    void HandMov(bool walking) {
      Hand1.Position = new Vector2(0, 40);
      Hand2.Position = new Vector2(0, 45);
      if(!walking) {
        if(!flip) {
          Hand1.Position += new Vector2(-40, 0);
          Hand2.Position += new Vector2(37, 0);
        } else {
          Hand1.Position += new Vector2(40, 0);
          Hand2.Position += new Vector2(-37, 0);
        }
        Hand1.Position -= new Vector2(0, (float)Math.Sin(funcTime*2+(float)Math.PI/3)*4f);
        Hand2.Position -= new Vector2(0, (float)Math.Sin(funcTime*2+(float)Math.PI/3)*4f);
      } else {
        if(flip) {
          Hand1.Position += new Vector2((float)Math.Sin(funcTime*7)*50f, 0);
          Hand2.Position -= new Vector2((float)Math.Sin(funcTime*7)*50f, 0);
        } else {
          Hand1.Position -= new Vector2((float)Math.Sin(funcTime*7)*50f, 0);
          Hand2.Position += new Vector2((float)Math.Sin(funcTime*7)*50f, 0);
        }
      }
    }

    void Step(double delta, bool flip, bool walking)
    {
				leg1.Call("Step", delta, 1, flip, walking);
        leg2.Call("Step", delta, 2, flip, walking); 
    }
}
